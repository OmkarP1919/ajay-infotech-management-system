import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/core/network/supabase_service.dart';
import 'package:ajay_infotech_app/core/services/notification_service.dart';
import 'package:ajay_infotech_app/data/repositories/mock_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase A: Session Persistence & Hardening Tests', () {
    test('SupabaseAuthUser serializes and deserializes correctly', () {
      final user = SupabaseAuthUser(
        id: 'u-1234',
        email: 'test@ajayinfotech.in',
        studentId: 'AI-2026-9999',
      );

      final json = user.toJson();
      final restored = SupabaseAuthUser.fromJson(json);

      expect(restored.id, 'u-1234');
      expect(restored.email, 'test@ajayinfotech.in');
      expect(restored.studentId, 'AI-2026-9999');
    });

    test('SupabaseAuthSession serializes and deserializes correctly', () {
      final session = SupabaseAuthSession(
        accessToken: 'mock_jwt_access_token',
        refreshToken: 'mock_refresh_token',
        user: SupabaseAuthUser(
          id: 'u-1234',
          email: 'test@ajayinfotech.in',
          studentId: 'AI-2026-9999',
        ),
      );

      final json = session.toJson();
      final restored = SupabaseAuthSession.fromJson(json);

      expect(restored.accessToken, 'mock_jwt_access_token');
      expect(restored.refreshToken, 'mock_refresh_token');
      expect(restored.user.email, 'test@ajayinfotech.in');
    });
  });

  group('Phase B: Push & Modular Notification Tests', () {
    test('NotificationService manages topic subscriptions', () async {
      await NotificationService.initialize();
      expect(NotificationService.isSubscribed(NotificationTopic.announcements),
          isTrue);
      expect(NotificationService.isSubscribed(NotificationTopic.feeReminders),
          isTrue);

      await NotificationService.unsubscribeFromTopic(
          NotificationTopic.feeReminders);
      expect(NotificationService.isSubscribed(NotificationTopic.feeReminders),
          isFalse);

      await NotificationService.subscribeToTopic(
          NotificationTopic.feeReminders);
      expect(NotificationService.isSubscribed(NotificationTopic.feeReminders),
          isTrue);
    });

    test('NotificationService posts and stores notifications in memory', () {
      NotificationService.clearAll();
      NotificationService.postNotification(
        title: 'Fee Payment Received',
        body: 'Your payment of ₹15,000 has been verified.',
        topic: NotificationTopic.feeReminders,
      );

      expect(NotificationService.notifications.length, 1);
      expect(NotificationService.notifications.first.title,
          'Fee Payment Received');
    });
  });

  group('Phase C: Admin Data Architecture & Reconciliation Tests', () {
    test('MockAppRepository executes admin operations successfully', () async {
      final repo = MockAppRepository();

      final batchCreated = await repo.createBatch({
        'name': 'Full Stack Java 2026',
        'code': 'FSJ-2026',
      });
      expect(batchCreated, isTrue);

      final courseCreated = await repo.createCourse({
        'title': 'Advanced Cloud Computing',
      });
      expect(courseCreated, isTrue);

      final announcementPosted = await repo.postAnnouncement({
        'title': 'Campus Placement Drive',
      });
      expect(announcementPosted, isTrue);

      final attendanceMarked = await repo.markAttendance({
        'status': 'present',
      });
      expect(attendanceMarked, isTrue);

      final leaveReviewed = await repo.reviewLeaveRequest('req-1', true);
      expect(leaveReviewed, isTrue);
    });

    test('reconcilePayments completes without error', () async {
      final repo = MockAppRepository();
      await expectLater(repo.reconcilePayments(), completes);
    });
  });
}
