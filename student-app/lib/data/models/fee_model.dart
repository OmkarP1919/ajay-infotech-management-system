enum InstallmentStatus { paid, pending, overdue }

class InstallmentModel {
  final String id;
  final String title;
  final double amount;
  final String dueDate;
  final String? paidDate;
  final String? receiptNo;
  final InstallmentStatus status;

  const InstallmentModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.receiptNo,
    required this.status,
  });
}

class TransactionModel {
  final String id;
  final String receiptNo;
  final String description;
  final double amount;
  final String date;
  final String paymentMethod;
  final String status;

  const TransactionModel({
    required this.id,
    required this.receiptNo,
    required this.description,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.status,
  });
}

class FeeSummaryModel {
  final double totalFee;
  final double paidAmount;
  final double outstandingAmount;
  final String nextDueDate;
  final List<InstallmentModel> installments;
  final List<TransactionModel> transactions;

  const FeeSummaryModel({
    required this.totalFee,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.nextDueDate,
    required this.installments,
    required this.transactions,
  });
}
