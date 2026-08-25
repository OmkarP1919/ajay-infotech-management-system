import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/core/network/supabase_service.dart';
import 'package:ajay_infotech_app/data/repositories/supabase_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseAppRepository Real Error Propagation Tests', () {
    late SupabaseAppRepository repository;

    setUp(() async {
      await SupabaseService.signOut(); // Ensure unauthenticated state
      repository = SupabaseAppRepository();
    });

    test(
        'getStudentProfile throws unauthenticated exception when not signed in',
        () async {
      expect(
        () => repository.getStudentProfile(),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'getAttendanceHistory throws unauthenticated exception when not signed in',
        () async {
      expect(
        () => repository.getAttendanceHistory(),
        throwsA(isA<Exception>()),
      );
    });

    test('getFeeSummary throws unauthenticated exception when not signed in',
        () async {
      expect(
        () => repository.getFeeSummary(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
