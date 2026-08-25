import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/core/network/supabase_service.dart';
import 'package:ajay_infotech_app/data/repositories/mock_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2: Supabase Storage & Security Unit Tests', () {
    test('Public URL generation formats correctly', () {
      final url = SupabaseService.getPublicUrl(
        'course-resources',
        'mern_architecture.pdf',
      );
      expect(url, contains('course-resources'));
      expect(url, contains('mern_architecture.pdf'));
      expect(url, startsWith('https://'));
    });

    test('Assignment submission validates allowed sizes and executes',
        () async {
      final repo = MockAppRepository();
      final smallFileBytes = Uint8List.fromList(List.filled(1024, 0)); // 1KB

      final result = await repo.submitAssignment(
        courseId: 'course-1',
        assignmentTitle: 'Assignment 3: REST API',
        fileName: 'solution.pdf',
        fileBytes: smallFileBytes,
      );

      expect(result, isTrue);
    });

    test('Course resources load PDF models correctly', () async {
      final repo = MockAppRepository();
      final courses = await repo.getCourses();
      expect(courses, isNotEmpty);

      final firstCourse = courses.first;
      expect(firstCourse.resources, isNotEmpty);
      expect(firstCourse.resources.first.type, 'PDF');
    });
  });

  group('Phase 2: Payment Verification & Ledger Unit Tests', () {
    test('Create payment order returns valid structure', () async {
      final repo = MockAppRepository();
      final order = await repo.createPaymentOrder('inst-1');
      expect(order, isNotNull);
      expect(order!['orderId'], isNotEmpty);
      expect(order['amount'], 1500000);
      expect(order['currency'], 'INR');
    });

    test('Payment verification succeeds and updates installment', () async {
      final repo = MockAppRepository();
      final verified = await repo.verifyAndProcessPayment(
        orderId: 'order_123',
        paymentId: 'pay_123',
        signature: 'sig_123',
        installmentId: 'inst-1',
      );
      expect(verified, isTrue);
    });

    test('Fee summary accurately calculates paid and outstanding amounts',
        () async {
      final repo = MockAppRepository();
      final summary = await repo.getFeeSummary();
      expect(summary.totalFee, greaterThan(0));
      expect(summary.paidAmount + summary.outstandingAmount, summary.totalFee);
    });
  });
}
