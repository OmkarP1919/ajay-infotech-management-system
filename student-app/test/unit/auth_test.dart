import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/data/repositories/auth_repository.dart';
import 'package:ajay_infotech_app/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier Tests', () {
    late AuthRepository repo;
    late AuthNotifier notifier;

    setUp(() {
      repo = AuthRepository();
      notifier = AuthNotifier(repo);
    });

    tearDown(() async {
      await repo.logout();
    });

    test('Initial state is unauthenticated', () {
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.studentId, isNull);
    });

    test('Login with valid credentials succeeds', () async {
      final success = await notifier.login(
        studentIdOrEmail: 'AI-2026-8842',
        password: 'password123',
      );
      expect(success, isTrue);
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.studentId, 'AI-2026-8842');
    });

    test('Login with empty credentials fails', () async {
      await repo.logout();
      final cleanNotifier = AuthNotifier(repo);
      final success = await cleanNotifier.login(
        studentIdOrEmail: '',
        password: '',
      );
      expect(success, isFalse);
      expect(cleanNotifier.state.status, AuthStatus.unauthenticated);
      expect(cleanNotifier.state.errorMessage, isNotNull);
    });

    test('Logout resets state to unauthenticated', () async {
      await notifier.login(
        studentIdOrEmail: 'AI-2026-8842',
        password: 'password123',
      );
      expect(notifier.state.status, AuthStatus.authenticated);

      await notifier.logout();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.studentId, isNull);
    });
  });
}
