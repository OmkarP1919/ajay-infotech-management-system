import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/data/repositories/app_repository.dart';
import 'package:ajay_infotech_app/data/repositories/mock_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Course & Repository Tests', () {
    late AppRepository repository;

    setUp(() {
      repository = MockAppRepository();
    });

    test('getCourses returns non-empty list', () async {
      final courses = await repository.getCourses();
      expect(courses, isNotEmpty);
      expect(courses.first.title, contains('Full Stack Masterclass'));
      expect(courses.first.modules, isNotEmpty);
    });

    test('getStudentProfile returns current student details', () async {
      final student = await repository.getStudentProfile();
      expect(student.name, 'Rohit Sharma');
      expect(student.registrationNo, 'AI-2026-8842');
      expect(student.overallAttendance, greaterThanOrEqualTo(75.0));
    });

    test('getBatches returns active and completed batches', () async {
      final batches = await repository.getBatches();
      expect(batches.any((b) => b.isActive), isTrue);
      expect(batches.any((b) => !b.isActive), isTrue);
    });
  });
}
