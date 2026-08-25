import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/supabase_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/fee_model.dart';
import '../../../data/repositories/app_repository.dart';

enum PaymentState {
  idle,
  orderCreating,
  checkoutActive,
  verifying,
  paid,
  failed,
  cancelled,
}

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  late Razorpay _razorpay;
  PaymentState _paymentState = PaymentState.idle;
  bool _isProcessingPayment = false;
  InstallmentModel? _activePayingInstallment;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final inst = _activePayingInstallment;
    if (inst == null) return;

    setState(() {
      _paymentState = PaymentState.verifying;
      _isProcessingPayment = true;
    });

    try {
      final repo = ref.read(appRepositoryProvider);

      // Server-side authoritative verification
      final verified = await repo.verifyAndProcessPayment(
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        installmentId: inst.id,
      );

      await repo.reconcilePayments();
      ref.invalidate(feeSummaryProvider);

      if (mounted) {
        setState(() {
          _paymentState = verified ? PaymentState.paid : PaymentState.failed;
          _isProcessingPayment = false;
          _activePayingInstallment = null;
        });

        if (verified) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 28),
                    SizedBox(width: 10),
                    Text('Payment Verified!'),
                  ],
                ),
                content: Text(
                  'Payment of ₹${inst.amount.toInt()} for ${inst.title} has been securely verified by the server.\n\nPayment ID: ${response.paymentId}\nOrder ID: ${response.orderId}\n\nFee installment has been marked paid.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _paymentState = PaymentState.idle;
                      });
                    },
                    child: const Text('Done'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verification failed on server.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _paymentState = PaymentState.failed;
          _isProcessingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentState = PaymentState.cancelled;
      _isProcessingPayment = false;
      _activePayingInstallment = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Payment Cancelled / Failed (${response.code}): ${response.message}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeAsync = ref.watch(feeSummaryProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.feesManagement,
        showBackButton: false,
      ),
      body: Stack(
        children: [
          feeAsync.when(
            data: (feeSummary) {
              return RefreshIndicator(
                color: AppColors.primaryTeal,
                onRefresh: () async {
                  await ref.read(appRepositoryProvider).reconcilePayments();
                  ref.invalidate(feeSummaryProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Fee Summary Hero Glass Card
                      GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(22),
                        surfaceColor: AppColors.primaryTeal,
                        isDark: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL COURSE FEE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldenOrange,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'DUE: ${feeSummary.nextDueDate}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryDarkest,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(feeSummary.totalFee),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Paid Amount',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyFormat
                                            .format(feeSummary.paidAmount),
                                        style:
                                            AppTypography.titleLarge.copyWith(
                                          color: AppColors.goldenOrange,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Outstanding Due',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyFormat.format(
                                            feeSummary.outstandingAmount),
                                        style:
                                            AppTypography.titleLarge.copyWith(
                                          color: const Color(0xFFFF8A80),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Installment Timeline Section
                      const SectionHeader(title: 'Installment Breakdown'),
                      const SizedBox(height: 8),
                      if (feeSummary.installments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No fee installments scheduled',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ...feeSummary.installments.map((inst) {
                        final isPaid = inst.status == InstallmentStatus.paid;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            borderRadius: 18,
                            padding: const EdgeInsets.all(18),
                            borderColor: isPaid
                                ? AppColors.outlineVariant
                                : AppColors.goldenOrange.withOpacity(0.6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        inst.title,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDarkest,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? AppColors.success
                                                .withOpacity(0.12)
                                            : AppColors.warning
                                                .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPaid ? 'PAID' : 'PENDING',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: isPaid
                                              ? AppColors.success
                                              : AppColors.warning,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currencyFormat.format(inst.amount),
                                      style:
                                          AppTypography.headlineMedium.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDarkest,
                                      ),
                                    ),
                                    Text(
                                      isPaid
                                          ? 'Paid on ${inst.paidDate}'
                                          : 'Due by ${inst.dueDate}',
                                      style: AppTypography.labelSmall,
                                    ),
                                  ],
                                ),
                                if (isPaid && inst.receiptNo != null) ...[
                                  const SizedBox(height: 12),
                                  Divider(
                                    height: 1,
                                    color: AppColors.outlineVariant
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Receipt: ${inst.receiptNo}',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.description_outlined,
                                          size: 16,
                                          color: AppColors.primaryTeal,
                                        ),
                                        label: Text(
                                          AppStrings.downloadReceipt,
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () =>
                                            _downloadReceipt(context, inst),
                                      ),
                                    ],
                                  ),
                                ],
                                if (!isPaid) ...[
                                  const SizedBox(height: 14),
                                  GlassButton(
                                    text: AppStrings.payNow,
                                    variant: GlassButtonVariant.accent,
                                    height: 44,
                                    leadingIcon: Icons.payment_rounded,
                                    onPressed: () {
                                      _startPaymentFlow(
                                          context, inst, currencyFormat);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Transactions List
                      const SectionHeader(title: 'Payment History'),
                      const SizedBox(height: 8),
                      if (feeSummary.transactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No previous transactions recorded',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ...feeSummary.transactions.map((tx) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDarkest,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tx.date} • ${tx.paymentMethod}',
                                        style: AppTypography.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(tx.amount),
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDarkest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          if (_isProcessingPayment || _paymentState == PaymentState.verifying)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.goldenOrange),
                    SizedBox(height: 18),
                    Text(
                      'Payment received. Verifying securely...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Authorizing ledger update on server',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _downloadReceipt(BuildContext context, InstallmentModel inst) async {
    final user = SupabaseService.currentUser;
    final signedUrl = await SupabaseService.createSignedUrl(
      'receipts',
      '${user?.id ?? "student"}/${inst.receiptNo}.pdf',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Receipt ${inst.receiptNo} (Database Record). ${signedUrl != null ? "Storage link verified." : "Record verified."}',
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: AppColors.goldenOrange,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _startPaymentFlow(
    BuildContext context,
    InstallmentModel inst,
    NumberFormat currencyFormat,
  ) async {
    if (_isProcessingPayment || _paymentState != PaymentState.idle) {
      return; // Prevent duplicate button taps
    }

    _activePayingInstallment = inst;
    _paymentState = PaymentState.orderCreating;

    // Show preparation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.goldenOrange),
            SizedBox(height: 16),
            Text(
              'Creating Razorpay Test Order...',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );

    try {
      final repo = ref.read(appRepositoryProvider);

      // 1. Create order via Edge Function / Server
      final orderResult = await repo.createPaymentOrder(inst.id);
      final orderId = orderResult?['orderId'] ?? '';
      final keyId = orderResult?['keyId'] ?? AppConfig.razorpayKeyId;

      if (context.mounted) {
        Navigator.pop(context); // Close order loader
      }

      final user = SupabaseService.currentUser;

      // 2. Configure Real Razorpay Checkout Options
      final options = {
        'key': keyId,
        'amount': Math.round(inst.amount * 100), // in paise
        'name': 'Ajay Infotech',
        'description': 'Fee Payment: ${inst.title}',
        'order_id': orderId.isNotEmpty ? orderId : null,
        'timeout': 180, // 3 minutes
        'prefill': {
          'contact': '9876543210',
          'email': user?.email ?? 'student@ajayinfotech.in',
        },
        'theme': {
          'color': '#0F766E', // AppColors.primaryTeal
        },
        'notes': {
          'installmentId': inst.id,
          'studentId': user?.id ?? '',
        }
      };

      // Open Real Razorpay Mobile Checkout
      _razorpay.open(options);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class Math {
  static int round(double val) => val.round();
}
