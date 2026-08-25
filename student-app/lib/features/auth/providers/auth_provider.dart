import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthState {
  final AuthStatus status;
  final String? studentId;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.studentId,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    String? studentId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    final savedId = await _authRepository.getSavedSession();
    if (savedId != null && savedId.isNotEmpty) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        studentId: savedId,
      );
    }
  }

  Future<bool> login({
    required String studentIdOrEmail,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);

    if (studentIdOrEmail.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Please enter valid credentials',
      );
      return false;
    }

    final success = await _authRepository.loginWithEmailOrId(
      studentIdOrEmail: studentIdOrEmail,
      password: password,
    );

    if (success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        studentId: studentIdOrEmail,
        errorMessage: null,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Invalid student credentials. Please verify and retry.',
      );
      return false;
    }
  }

  Future<bool> loginWithOtp({
    required String phoneOrId,
    required String otp,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);

    if (otp.length < 4) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Please enter a 4-digit OTP',
      );
      return false;
    }

    final success = await _authRepository.loginWithOtp(
      phoneOrId: phoneOrId,
      otp: otp,
    );

    if (success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        studentId: phoneOrId,
        errorMessage: null,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Invalid OTP code entered.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState.initial();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
