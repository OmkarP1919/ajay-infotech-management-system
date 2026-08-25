import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final feesAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await Supabase.instance.client
      .from('fees')
      .select('*, profiles(full_name, student_id, batch_code), fee_installments(*)')
      .order('updated_at', ascending: false);
  return List<Map<String, dynamic>>.from(data);
});

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(feesAdminProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Fees & Payments',
          subtitle: 'Monitor student fee status and outstanding dues',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  controller: _searchCtrl,
                  hint: 'Search by student name or ID...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 10),
              ..._buildFilterChips(),
            ],
          ),
        ),
        Expanded(
          child: feesAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString(),
                onRetry: () => ref.invalidate(feesAdminProvider)),
            data: (fees) {
              var filtered = fees;
              if (_query.isNotEmpty) {
                final q = _query.toLowerCase();
                filtered = filtered.where((f) {
                  final p = f['profiles'] as Map<String, dynamic>?;
                  return (p?['full_name'] ?? '').toLowerCase().contains(q) ||
                      (p?['student_id'] ?? '').toLowerCase().contains(q);
                }).toList();
              }
              if (_filter == 'Outstanding') {
                filtered = filtered
                    .where((f) =>
                        (f['outstanding_amount'] as num? ?? 0) > 0)
                    .toList();
              }

              if (filtered.isEmpty) {
                return const AdminEmptyState(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'No fee records found',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AdminCard(
                  padding: EdgeInsets.zero,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                            color: AdminColors.background),
                        children: [
                          _TH('Student'), _TH('Total Fee'), _TH('Paid'),
                          _TH('Outstanding'), _TH('Next Due'), _TH('Status'),
                        ],
                      ),
                      ...filtered.map((f) {
                        final profile =
                            f['profiles'] as Map<String, dynamic>?;
                        final total =
                            (f['total_fee'] as num? ?? 0).toDouble();
                        final paid =
                            (f['paid_amount'] as num? ?? 0).toDouble();
                        final outstanding =
                            (f['outstanding_amount'] as num? ?? 0).toDouble();
                        final pct = total > 0 ? paid / total : 0.0;
                        final hasOutstanding = outstanding > 0;

                        return TableRow(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AdminColors.divider))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile?['full_name'] ?? '—',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      '${profile?['student_id'] ?? ''} · ${profile?['batch_code'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AdminColors.textMuted)),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: pct.clamp(0.0, 1.0),
                                    backgroundColor:
                                        AdminColors.divider,
                                    color: AdminColors.success,
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ],
                              ),
                            ),
                            _TD('₹${NumberFormat('#,##,###').format(total)}'),
                            _TD('₹${NumberFormat('#,##,###').format(paid)}',
                                color: AdminColors.success),
                            _TD('₹${NumberFormat('#,##,###').format(outstanding)}',
                                color: hasOutstanding
                                    ? AdminColors.error
                                    : AdminColors.textPrimary),
                            _TD(f['next_due_date'] ?? '—'),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: AdminStatusBadge(
                                label: outstanding > 0 ? 'DUES' : 'CLEARED',
                                type: outstanding > 0
                                    ? AdminBadgeType.error
                                    : AdminBadgeType.success,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFilterChips() {
    return ['All', 'Outstanding'].map((f) {
      final selected = _filter == f;
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: FilterChip(
          label: Text(f),
          selected: selected,
          onSelected: (_) => setState(() => _filter = f),
          selectedColor: AdminColors.primaryTeal,
          labelStyle: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AdminColors.textSecondary,
          ),
          side: const BorderSide(color: AdminColors.cardBorder),
          backgroundColor: AdminColors.surface,
          showCheckmark: false,
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      );
    }).toList();
  }

  Widget _TH(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted)));

  Widget _TD(String t, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Text(t, style: TextStyle(fontSize: 12, color: color ?? AdminColors.textPrimary, fontWeight: FontWeight.w600)));
}
