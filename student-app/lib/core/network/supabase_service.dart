import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SupabaseAuthUser {
  final String id;
  final String email;
  final String? studentId;

  SupabaseAuthUser({
    required this.id,
    required this.email,
    this.studentId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'studentId': studentId,
      };

  factory SupabaseAuthUser.fromJson(Map<String, dynamic> json) =>
      SupabaseAuthUser(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        studentId: json['studentId'],
      );
}

class SupabaseAuthSession {
  final String accessToken;
  final String refreshToken;
  final SupabaseAuthUser user;

  SupabaseAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };

  factory SupabaseAuthSession.fromJson(Map<String, dynamic> json) =>
      SupabaseAuthSession(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        user: SupabaseAuthUser.fromJson(json['user'] ?? {}),
      );
}

class SupabaseService {
  static bool _isInitialized = false;
  static SupabaseAuthSession? _currentSession;
  static const String _sessionKey = 'ajay_infotech_auth_session';

  static bool get isInitialized => _isInitialized;
  static SupabaseAuthUser? get currentUser => _currentSession?.user;
  static String? get accessToken => _currentSession?.accessToken;
  static bool get isAuthenticated => _currentSession != null;

  static Future<void> initialize() async {
    _isInitialized = true;
    await restoreSession();
    if (kDebugMode) {
      print(
          'Supabase REST & Storage client initialized: ${AppConfig.supabaseUrl}');
    }
  }

  /// Restore persistent session from SharedPreferences
  static Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStr = prefs.getString(_sessionKey);
      if (sessionStr != null && sessionStr.isNotEmpty) {
        final decoded = jsonDecode(sessionStr);
        _currentSession = SupabaseAuthSession.fromJson(decoded);
        return true;
      }
    } catch (_) {
      // Ignored in unit testing environments without native platform channels
    }
    return false;
  }

  /// Save session to persistent storage
  static Future<void> _saveSession(SupabaseAuthSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    } catch (_) {
      // Ignored in unit testing environments
    }
  }

  /// Clear persistent session on logout
  static Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {
      // Ignored in unit testing environments
    }
  }

  static void setSessionForTesting(SupabaseAuthSession session) {
    _currentSession = session;
  }

  /// Check connectivity / server health
  static Future<bool> checkConnectivity() async {
    try {
      final uri = Uri.parse('${AppConfig.supabaseUrl}/rest/v1/');
      final response = await http
          .get(uri, headers: {'apikey': AppConfig.supabaseAnonKey}).timeout(
        const Duration(seconds: 4),
      );
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  static Map<String, String> get _defaultHeaders {
    final headers = {
      'apikey': AppConfig.supabaseAnonKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
    if (_currentSession != null) {
      headers['Authorization'] = 'Bearer ${_currentSession!.accessToken}';
    } else {
      headers['Authorization'] = 'Bearer ${AppConfig.supabaseAnonKey}';
    }
    return headers;
  }

  /// Execute PostgREST query on Supabase table
  static Future<List<Map<String, dynamic>>> queryTable(
    String table, {
    String select = '*',
    Map<String, String>? filters,
    String? order,
  }) async {
    try {
      final queryParams = {'select': select};
      if (filters != null) {
        queryParams.addAll(filters);
      }
      if (order != null) {
        queryParams['order'] = order;
      }

      final uri = Uri.parse('${AppConfig.supabaseUrl}/rest/v1/$table')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase queryTable error ($table): $e');
      }
    }
    return [];
  }

  /// Insert record into Supabase table
  static Future<Map<String, dynamic>?> insertRecord(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('${AppConfig.supabaseUrl}/rest/v1/$table');
      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.first;
        } else if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase insertRecord error ($table): $e');
      }
    }
    return null;
  }

  /// Update record in Supabase table
  static Future<bool> updateRecord(
    String table,
    Map<String, dynamic> data, {
    required Map<String, String> filters,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.supabaseUrl}/rest/v1/$table')
          .replace(queryParameters: filters);
      final response = await http.patch(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print('Supabase updateRecord error ($table): $e');
      }
    }
    return false;
  }

  // ===========================================================================
  // SUPABASE STORAGE OPERATIONS
  // ===========================================================================

  /// Get public URL for a storage object in a public bucket
  static String getPublicUrl(String bucket, String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConfig.supabaseUrl}/storage/v1/object/public/$bucket/$cleanPath';
  }

  /// Create a signed URL for secure private storage access
  static Future<String?> createSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
  }) async {
    try {
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final uri = Uri.parse(
          '${AppConfig.supabaseUrl}/storage/v1/object/sign/$bucket/$cleanPath');
      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode({'expiresIn': expiresInSeconds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['signedURL'] != null) {
          return '${AppConfig.supabaseUrl}/storage/v1${data['signedURL']}';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase createSignedUrl error ($bucket/$path): $e');
      }
    }
    return null;
  }

  /// Upload file bytes to Supabase Storage
  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    try {
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final uri = Uri.parse(
          '${AppConfig.supabaseUrl}/storage/v1/object/$bucket/$cleanPath');

      final headers = Map<String, String>.from(_defaultHeaders);
      headers['Content-Type'] = contentType;
      headers['x-upsert'] = 'true';

      final response = await http.post(
        uri,
        headers: headers,
        body: fileBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return getPublicUrl(bucket, cleanPath);
      } else {
        if (kDebugMode) {
          print(
              'Storage upload failed: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase uploadFile error ($bucket/$path): $e');
      }
    }
    return null;
  }

  // ===========================================================================
  // SUPABASE EDGE FUNCTIONS
  // ===========================================================================

  /// Invoke Supabase Edge Function
  static Future<Map<String, dynamic>?> invokeFunction(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final uri =
          Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$functionName');
      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print(
              'Edge Function ($functionName) HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase invokeFunction error ($functionName): $e');
      }
    }
    return null;
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  /// Sign In with Email / Student ID & Password
  static Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.supabaseUrl}/auth/v1/token?grant_type=password');
      final response = await http.post(
        uri,
        headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final session = SupabaseAuthSession(
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
          user: SupabaseAuthUser(
            id: data['user']?['id'] ?? '',
            email: data['user']?['email'] ?? email,
            studentId: email.split('@').first,
          ),
        );
        _currentSession = session;
        await _saveSession(session);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase signInWithPassword error: $e');
      }
    }
    return false;
  }

  /// Sign Out
  static Future<void> signOut() async {
    _currentSession = null;
    await _clearSession();
  }
}
