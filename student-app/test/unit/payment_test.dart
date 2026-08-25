import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/features/fees/services/payment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaymentService Integration Tests', () {
    test(
        'createPaymentOrder creates a valid order object with currency and keyId',
        () async {
      final order = await PaymentService.createPaymentOrder(
        installmentId: 'inst_02',
        amount: 15000.0,
        studentId: 'AI-2026-8842',
      );

      expect(order, isNotNull);
      expect(order!.orderId, isNotEmpty);
      expect(order.amount, 15000.0);
      expect(order.currency, 'INR');
      expect(order.keyId, isNotEmpty);
    });
  });
}
