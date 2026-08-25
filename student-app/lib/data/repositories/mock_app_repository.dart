import 'dart:typed_data';
import '../mock_data/mock_database.dart';
import '../models/attendance_model.dart';
import '../models/batch_model.dart';
import '../models/course_model.dart';
import '../models/fee_model.dart';
import '../models/student_model.dart';
import '../models/announcement_model.dart';
import 'app_repository.dart';

/// Explicit Mock repository for automated test suites and isolated UI widget tests
class MockAppRepository implements AppRepository {
  @override
  Future<StudentModel> getStudentProfile() async {
    return MockDatabase.currentStudent;
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    return MockDatabase.courses;
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final courses = await getCourses();
    return courses.firstWhere(
      (c) => c.id == id,
      orElse: () => courses.first,
    );
  }

  @override
  Future<List<BatchModel>> getBatches() async {
    return MockDatabase.batches;
  }

  @override
  Future<List<SubjectAttendance>> getSubjectAttendance() async {
    return MockDatabase.subjectAttendances;
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistory() async {
    return MockDatabase.attendanceRecords;
  }

  @override
  Future<FeeSummaryModel> getFeeSummary() async {
    return MockDatabase.feeSummary;
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    return MockDatabase.announcements;
  }

  @override
  Future<bool> submitAssignment({
    required String courseId,
    required String assignmentTitle,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    return true;
  }

  @override
  Future<Map<String, dynamic>?> createPaymentOrder(String installmentId) async {
    return {
      'orderId': 'order_mock_123456',
      'amount': 1500000,
      'currency': 'INR',
      'keyId': 'rzp_test_mockKey',
      'installmentTitle': 'Installment Fee',
    };
  }

  @override
  Future<bool> verifyAndProcessPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String installmentId,
  }) async {
    return true;
  }

  @override
  Future<void> reconcilePayments() async {}

  @override
  Future<bool> createBatch(Map<String, dynamic> batchData) async => true;

  @override
  Future<bool> createCourse(Map<String, dynamic> courseData) async => true;

  @override
  Future<bool> postAnnouncement(Map<String, dynamic> announcementData) async =>
      true;

  @override
  Future<bool> markAttendance(Map<String, dynamic> attendanceData) async =>
      true;

  @override
  Future<bool> reviewLeaveRequest(String requestId, bool approved) async =>
      true;
}
