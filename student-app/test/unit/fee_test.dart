import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/data/models/fee_model.dart';
import 'package:ajay_infotech_app/data/repositories/app_repository.dart';
import 'package:ajay_infotech_app/data/repositories/mock_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fees & Payments Tests', () {
    late AppRepository repository;

    setUp(() {
      repository = MockAppRepository();
    });

    test('getFeeSummary returns correct calculations', () async {
      final summary = await repository.getFeeSummary();
      expect(summary.totalFee, 45000.0);
      expect(summary.paidAmount, 30000.0);
      expect(summary.outstandingAmount, 15000.0);
      expect(summary.paidAmount + summary.outstandingAmount, summary.totalFee);
    });

    test('Installments have valid status', () async {
      final summary = await repository.getFeeSummary();
      expect(summary.installments.length, 3);
      expect(summary.installments.first.status, InstallmentStatus.paid);
      expect(summary.installments.first.receiptNo, isNotNull);
      expect(summary.installments.last.status, InstallmentStatus.pending);
    });
  });
}
