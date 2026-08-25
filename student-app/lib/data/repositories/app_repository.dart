import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';
import '../models/batch_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_model.dart';
import '../models/announcement_model.dart';
import 'supabase_app_repository.dart';

abstract class AppRepository {
  Future<StudentModel> getStudentProfile();
  Future<List<CourseModel>> getCourses();
  Future<CourseModel?> getCourseById(String id);
  Future<List<BatchModel>> getBatches();
  Future<List<SubjectAttendance>> getSubjectAttendance();
  Future<List<AttendanceRecord>> getAttendanceHistory();
  Future<FeeSummaryModel> getFeeSummary();
  Future<List<AnnouncementModel>> getAnnouncements();

  // Phase 2: Storage & Payments
  Future<bool> submitAssignment({
    required String courseId,
    required String assignmentTitle,
    required String fileName,
    required Uint8List fileBytes,
  });
  Future<Map<String, dynamic>?> createPaymentOrder(String installmentId);
  Future<bool> verifyAndProcessPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String installmentId,
  });
  Future<void> reconcilePayments();

  // Phase C: Admin-Ready Operations
  Future<bool> createBatch(Map<String, dynamic> batchData);
  Future<bool> createCourse(Map<String, dynamic> courseData);
  Future<bool> postAnnouncement(Map<String, dynamic> announcementData);
  Future<bool> markAttendance(Map<String, dynamic> attendanceData);
  Future<bool> reviewLeaveRequest(String requestId, bool approved);
}

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return SupabaseAppRepository();
});

final studentProfileProvider = FutureProvider<StudentModel>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getStudentProfile();
});

final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getCourses();
});

final batchesProvider = FutureProvider<List<BatchModel>>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getBatches();
});

final attendanceProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getAttendanceHistory();
});

final subjectAttendanceProvider =
    FutureProvider<List<SubjectAttendance>>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getSubjectAttendance();
});

final feeSummaryProvider = FutureProvider<FeeSummaryModel>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getFeeSummary();
});

final announcementsProvider =
    FutureProvider<List<AnnouncementModel>>((ref) async {
  final repo = ref.watch(appRepositoryProvider);
  return repo.getAnnouncements();
});
