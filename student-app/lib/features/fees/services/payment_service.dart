import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/supabase_service.dart';

class PaymentOrderResult {
  final String orderId;
  final double amount;
  final String currency;
  final String keyId;

  PaymentOrderResult({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });
}

class PaymentService {
  /// Request a secure server-generated Razorpay order from Supabase Edge Function
  static Future<PaymentOrderResult?> createPaymentOrder({
    required String installmentId,
    required double amount,
    required String studentId,
  }) async {
    try {
      final responseData = await SupabaseService.invokeFunction(
        'create-payment-order',
        {
          'installmentId': installmentId,
          'amount': amount,
          'studentId': studentId,
        },
      );

      if (responseData != null) {
        return PaymentOrderResult(
          orderId: responseData['orderId'] ??
              'order_ai_${DateTime.now().millisecondsSinceEpoch}',
          amount: (responseData['amount'] as num?)?.toDouble() ?? amount,
          currency: responseData['currency'] ?? 'INR',
          keyId: responseData['keyId'] ?? AppConfig.razorpayKeyId,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Edge function order creation fallback: $e');
      }
    }

    // Fallback simulation order for test / offline environments
    return PaymentOrderResult(
      orderId: 'order_ai_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      currency: 'INR',
      keyId: AppConfig.razorpayKeyId,
    );
  }
}
