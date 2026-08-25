import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminAuthProvider = StreamProvider<Session?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session;
  });
});

final currentAdminProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return null;

  try {
    final result = await Supabase.instance.client
        .from('admin_users')
        .select('id, full_name, email, role, is_active')
        .eq('id', session.user.id)
        .eq('is_active', true)
        .maybeSingle();
    return result;
  } catch (_) {
    return null;
  }
});

final isAdminProvider = Provider<bool>((ref) {
  final admin = ref.watch(currentAdminProvider);
  return admin.value != null;
});

final isSuperAdminProvider = Provider<bool>((ref) {
  final admin = ref.watch(currentAdminProvider);
  return admin.value?['role'] == 'super_admin';
});
