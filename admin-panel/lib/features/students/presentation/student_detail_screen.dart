import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final studentDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final profile = await Supabase.instance.client
      .from('profiles')
      .select('*')
      .eq('id', id)
      .maybeSingle();
  if (profile == null) return null;

  final fees = await Supabase.instance.client
      .from('fees')
      .select('*, fee_installments(*)')
      .eq('student_id', id)
      .maybeSingle();

  final attendance = await Supabase.instance.client
      .from('attendance')
      .select('*')
      .eq('student_id', id)
      .order('date', ascending: false)
      .limit(20);

  final payments = await Supabase.instance.client
      .from('payments')
      .select('*')
      .eq('student_id', id)
      .order('created_at', ascending: false)
      .limit(10);

  return {
    'profile': profile,
    'fees': fees,
    'attendance': attendance,
    'payments': payments,
  };
});

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(studentDetailProvider(studentId));

    return dataAsync.when(
      loading: () => const Scaffold(body: AdminLoadingSpinner()),
      error: (e, _) => Scaffold(body: AdminErrorState(message: e.toString())),
      data: (data) {
        if (data == null) {
          return Scaffold(
            body: AdminEmptyState(
              icon: Icons.person_off_rounded,
              title: 'Student not found',
              action: ElevatedButton(
                onPressed: () => context.go('/students'),
                child: const Text('Back to Students'),
              ),
            ),
          );
        }

        final profile = data['profile'] as Map<String, dynamic>;
        final fees = data['fees'] as Map<String, dynamic>?;
        final attendance = List<Map<String, dynamic>>.from(data['attendance'] ?? []);
        final payments = List<Map<String, dynamic>>.from(data['payments'] ?? []);

        return Column(
          children: [
            AdminPageHeader(
              title: profile['full_name'] ?? 'Student',
              subtitle: '${profile['student_id']} · ${profile['program'] ?? ''}',
              actions: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded, size: 14),
                  label: const Text('Back'),
                  onPressed: () => context.go('/students'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _ProfileCard(profile: profile),
                          const SizedBox(height: 16),
                          _FeeCard(fees: fees),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right column
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _AttendanceCard(attendance: attendance),
                          const SizedBox(height: 16),
                          _PaymentsCard(payments: payments),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Student Profile',
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: profile['avatar_url'] != null
                ? NetworkImage(profile['avatar_url'])
                : null,
            backgroundColor: AdminColors.primaryTeal,
            child: profile['avatar_url'] == null
                ? Text(
                    (profile['full_name'] ?? 'S').substring(0, 1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(profile['full_name'] ?? 'Unknown',
              style: Theme.of(context).textTheme.titleLarge),
          Text(profile['student_id'] ?? '',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.email_outlined, label: profile['email'] ?? '—'),
          _InfoRow(icon: Icons.phone_outlined, label: profile['phone'] ?? '—'),
          _InfoRow(icon: Icons.school_rounded, label: profile['batch_code'] ?? '—'),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: profile['enrolled_date'] ?? '—',
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance', style: TextStyle(fontSize: 12, color: AdminColors.textMuted)),
              Text(
                '${(profile['overall_attendance'] as num? ?? 0).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: (profile['overall_attendance'] as num? ?? 0) >= 75
                      ? AdminColors.success
                      : AdminColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AdminColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final Map<String, dynamic>? fees;
  const _FeeCard({this.fees});

  @override
  Widget build(BuildContext context) {
    if (fees == null) {
      return const AdminCard(
        title: 'Fee Summary',
        child: AdminEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No fee record found'),
      );
    }

    final installments =
        List<Map<String, dynamic>>.from(fees!['fee_installments'] ?? []);
    return AdminCard(
      title: 'Fee Summary',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FeeStatItem(
                  label: 'Total Fee',
                  value: '₹${NumberFormat('#,##,###').format(fees!['total_fee'] ?? 0)}',
                  color: AdminColors.textPrimary,
                ),
              ),
              Expanded(
                child: _FeeStatItem(
                  label: 'Paid',
                  value: '₹${NumberFormat('#,##,###').format(fees!['paid_amount'] ?? 0)}',
                  color: AdminColors.success,
                ),
              ),
              Expanded(
                child: _FeeStatItem(
                  label: 'Outstanding',
                  value: '₹${NumberFormat('#,##,###').format(fees!['outstanding_amount'] ?? 0)}',
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...installments.map((inst) {
            final status = inst['status'] ?? 'pending';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AdminStatusBadge(
                    label: status.toUpperCase(),
                    type: status == 'paid'
                        ? AdminBadgeType.success
                        : status == 'overdue'
                            ? AdminBadgeType.error
                            : AdminBadgeType.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(inst['title'] ?? '',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Text(
                      '₹${NumberFormat('#,##,###').format(inst['amount'] ?? 0)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeeStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FeeStatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AdminColors.textMuted)),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final List<Map<String, dynamic>> attendance;
  const _AttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Recent Attendance',
      padding: EdgeInsets.zero,
      child: attendance.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: AdminEmptyState(
                  icon: Icons.fact_check_outlined, title: 'No attendance records'),
            )
          : Column(
              children: attendance.take(8).map((a) {
                final status = a['status'] ?? 'absent';
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AdminColors.divider))),
                  child: Row(
                    children: [
                      Text(a['date'] ?? '—',
                          style: const TextStyle(
                              fontSize: 12, color: AdminColors.textSecondary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(a['subject'] ?? '',
                              style: const TextStyle(fontSize: 12))),
                      AdminStatusBadge(
                        label: status.toUpperCase(),
                        type: status == 'present'
                            ? AdminBadgeType.success
                            : status == 'leave'
                                ? AdminBadgeType.warning
                                : AdminBadgeType.error,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  const _PaymentsCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Payment History',
      padding: EdgeInsets.zero,
      child: payments.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: AdminEmptyState(
                  icon: Icons.payment_outlined, title: 'No payment history'),
            )
          : Column(
              children: payments.map((p) {
                final date =
                    DateTime.tryParse(p['created_at'] ?? '');
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AdminColors.divider))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['razorpay_payment_id'] ?? p['id'] ?? '—',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textMuted,
                                  fontFamily: 'monospace'),
                            ),
                            Text(
                              date != null
                                  ? DateFormat('d MMM y, HH:mm').format(date)
                                  : '—',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${NumberFormat('#,##,###').format(p['amount'] ?? 0)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary),
                      ),
                      const SizedBox(width: 10),
                      AdminStatusBadge(
                        label: (p['status'] ?? 'pending').toUpperCase(),
                        type: p['status'] == 'success'
                            ? AdminBadgeType.success
                            : AdminBadgeType.error,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
