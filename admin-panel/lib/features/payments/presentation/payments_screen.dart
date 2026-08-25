import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final paymentsAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await Supabase.instance.client
      .from('payments')
      .select('*, profiles(full_name, student_id)')
      .order('created_at', ascending: false)
      .limit(200);
  return List<Map<String, dynamic>>.from(data);
});

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsAdminProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Payments',
          subtitle: 'All Razorpay payment transactions',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AdminSearchBar(
            controller: _searchCtrl,
            hint: 'Search by student name, payment ID...',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: paymentsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) =>
                AdminErrorState(message: e.toString()),
            data: (payments) {
              // Summary stats
              final success = payments.where((p) => p['status'] == 'success');
              final totalCollected = success.fold<double>(
                  0, (sum, p) => sum + (p['amount'] as num? ?? 0).toDouble());

              var filtered = payments;
              if (_query.isNotEmpty) {
                final q = _query.toLowerCase();
                filtered = filtered.where((p) {
                  final profile = p['profiles'] as Map<String, dynamic>?;
                  return (profile?['full_name'] ?? '').toLowerCase().contains(q) ||
                      (p['razorpay_payment_id'] ?? '').toLowerCase().contains(q) ||
                      (p['razorpay_order_id'] ?? '').toLowerCase().contains(q);
                }).toList();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Summary row
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Total Collected',
                            value: '₹${NumberFormat('#,##,###').format(totalCollected)}',
                            color: AdminColors.success,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: 'Successful',
                            value: '${success.length}',
                            color: AdminColors.success,
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: 'Failed',
                            value: '${payments.where((p) => p['status'] == 'failed').length}',
                            color: AdminColors.error,
                            icon: Icons.cancel_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: 'Total Transactions',
                            value: '${payments.length}',
                            color: AdminColors.info,
                            icon: Icons.receipt_long_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminCard(
                      padding: EdgeInsets.zero,
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: AdminEmptyState(
                                  icon: Icons.payment_rounded,
                                  title: 'No payments found'),
                            )
                          : Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2.5),
                                1: FlexColumnWidth(2.5),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(1.5),
                                4: FlexColumnWidth(2),
                                5: FlexColumnWidth(1.5),
                              },
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(
                                      color: AdminColors.background),
                                  children: [
                                    _TH('Student'),
                                    _TH('Payment ID'),
                                    _TH('Amount'),
                                    _TH('Status'),
                                    _TH('Date'),
                                    _TH('Method'),
                                  ],
                                ),
                                ...filtered.map((p) {
                                  final profile = p['profiles'] as Map<String, dynamic>?;
                                  final date = DateTime.tryParse(p['created_at'] ?? '');
                                  final status = p['status'] ?? 'pending';
                                  return TableRow(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: AdminColors.divider))),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(profile?['full_name'] ?? '—',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600)),
                                            Text(profile?['student_id'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AdminColors.textMuted)),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SelectableText(
                                          p['razorpay_payment_id'] ?? '—',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                              color: AdminColors.textSecondary),
                                        ),
                                      ),
                                      _TD('₹${NumberFormat('#,##,###').format(p['amount'] ?? 0)}',
                                          bold: true),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: AdminStatusBadge(
                                          label: status.toUpperCase(),
                                          type: status == 'success'
                                              ? AdminBadgeType.success
                                              : status == 'failed'
                                                  ? AdminBadgeType.error
                                                  : AdminBadgeType.warning,
                                        ),
                                      ),
                                      _TD(date != null
                                          ? DateFormat('d MMM y\nHH:mm').format(date)
                                          : '—'),
                                      _TD(p['payment_method'] ?? '—'),
                                    ],
                                  );
                                }),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _TH(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted)));

  Widget _TD(String t, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(t, style: TextStyle(fontSize: 12, color: AdminColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)));
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
