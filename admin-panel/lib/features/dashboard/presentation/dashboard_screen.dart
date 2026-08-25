import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final recentPayments = ref.watch(recentPaymentsProvider);
    final attendanceTrend = ref.watch(attendanceTrendProvider);
    final pendingLeaves = ref.watch(pendingLeavesCountProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Dashboard',
          subtitle: 'Live institute overview and analytics',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                stats.when(
                  loading: () => const _StatsSkeleton(),
                  error: (e, _) => AdminErrorState(message: e.toString()),
                  data: (data) => _StatsGrid(stats: data),
                ),
                const SizedBox(height: 24),
                // Charts Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fee collection chart
                    Expanded(
                      flex: 6,
                      child: AdminCard(
                        title: 'Fee Collection (Last 6 Months)',
                        headerActions: [
                          TextButton(
                            onPressed: () => context.go('/fees'),
                            child: const Text('View All',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        child: SizedBox(
                          height: 200,
                          child: recentPayments.when(
                            loading: () => const AdminLoadingSpinner(),
                            error: (e, _) =>
                                AdminErrorState(message: e.toString()),
                            data: (payments) =>
                                _FeeBarChart(payments: payments),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Attendance Pie
                    Expanded(
                      flex: 4,
                      child: AdminCard(
                        title: 'Today\'s Attendance',
                        child: SizedBox(
                          height: 200,
                          child: attendanceTrend.when(
                            loading: () => const AdminLoadingSpinner(),
                            error: (e, _) =>
                                AdminErrorState(message: e.toString()),
                            data: (data) => _AttendancePieChart(data: data),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Activity
                    Expanded(
                      flex: 6,
                      child: AdminCard(
                        title: 'Recent Payments',
                        headerActions: [
                          TextButton(
                            onPressed: () => context.go('/payments'),
                            child: const Text('View All',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        padding: EdgeInsets.zero,
                        child: recentPayments.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(20),
                            child: AdminLoadingSpinner(),
                          ),
                          error: (e, _) => AdminErrorState(message: e.toString()),
                          data: (payments) => _RecentPaymentsTable(
                              payments: payments.take(6).toList()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Quick actions
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          AdminCard(
                            title: 'Quick Actions',
                            child: _QuickActions(),
                          ),
                          const SizedBox(height: 16),
                          _PendingLeavesWidget(
                            count: pendingLeaves.value ?? 0,
                            onTap: () => context.go('/leave-requests'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.7,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AdminStatCard(
          label: 'Total Students',
          value: stats['total_students']?.toString() ?? '0',
          icon: Icons.people_rounded,
          color: AdminColors.primaryTeal,
          change: '+${stats['new_students_month'] ?? 0} this month',
          positive: true,
        ),
        AdminStatCard(
          label: 'Active Batches',
          value: stats['active_batches']?.toString() ?? '0',
          icon: Icons.school_rounded,
          color: AdminColors.gold,
        ),
        AdminStatCard(
          label: 'Fee Collection (Month)',
          value:
              '₹${NumberFormat('#,##,###').format(stats['month_collection'] ?? 0)}',
          icon: Icons.account_balance_wallet_rounded,
          color: AdminColors.success,
          change: '${stats['collection_pct'] ?? 0}% of target',
          positive: (stats['collection_pct'] ?? 0) >= 70,
        ),
        AdminStatCard(
          label: 'Pending Payments',
          value: stats['outstanding_count']?.toString() ?? '0',
          icon: Icons.pending_actions_rounded,
          color: AdminColors.error,
          change: '₹${NumberFormat('#,##,###').format(stats['outstanding_amount'] ?? 0)} due',
          positive: false,
        ),
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.7,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
          4,
          (_) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSkeleton(height: 36, width: 36, borderRadius: 8),
                    const Spacer(),
                    const AdminSkeleton(height: 26, width: 80),
                    const SizedBox(height: 6),
                    const AdminSkeleton(height: 12, width: 120),
                  ],
                ),
              )),
    );
  }
}

class _FeeBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  const _FeeBarChart({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const AdminEmptyState(
          icon: Icons.bar_chart_rounded, title: 'No payment data available');
    }

    // Group by month
    final Map<String, double> monthlyTotals = {};
    for (final p in payments) {
      final date = DateTime.tryParse(p['created_at'] ?? '') ?? DateTime.now();
      final key = DateFormat('MMM').format(date);
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + (p['amount'] as num? ?? 0).toDouble();
    }

    final entries = monthlyTotals.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries.isEmpty
            ? 100
            : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) *
                1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AdminColors.primaryDarkest,
            getTooltipItem: (group, _, rod, __) {
              final label = entries[group.x].key;
              return BarTooltipItem(
                '$label\n₹${NumberFormat('#,##,###').format(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox();
                }
                return Text(
                  entries[idx].key,
                  style: const TextStyle(
                      color: AdminColors.textMuted, fontSize: 11),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AdminColors.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          entries.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value,
                color: AdminColors.primaryTeal,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendancePieChart extends StatelessWidget {
  final Map<String, int> data;
  const _AttendancePieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final present = data['present'] ?? 0;
    final absent = data['absent'] ?? 0;
    final leave = data['leave'] ?? 0;
    final total = present + absent + leave;

    if (total == 0) {
      return const AdminEmptyState(
          icon: Icons.fact_check_rounded, title: 'No attendance data today');
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: present.toDouble(),
                  color: AdminColors.success,
                  title: '$present',
                  radius: 40,
                  titleStyle: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                PieChartSectionData(
                  value: absent.toDouble(),
                  color: AdminColors.error,
                  title: '$absent',
                  radius: 40,
                  titleStyle: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                if (leave > 0)
                  PieChartSectionData(
                    value: leave.toDouble(),
                    color: AdminColors.warning,
                    title: '$leave',
                    radius: 40,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendDot(color: AdminColors.success, label: 'Present: $present'),
            const SizedBox(height: 8),
            _LegendDot(color: AdminColors.error, label: 'Absent: $absent'),
            const SizedBox(height: 8),
            _LegendDot(color: AdminColors.warning, label: 'Leave: $leave'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AdminColors.textSecondary)),
      ],
    );
  }
}

class _RecentPaymentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  const _RecentPaymentsTable({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: AdminEmptyState(
            icon: Icons.payment_rounded, title: 'No recent payments'),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AdminColors.divider))),
          children: [
            _TH('Student'),
            _TH('Amount'),
            _TH('Date'),
            _TH('Status'),
          ],
        ),
        ...payments.map((p) {
          final date = DateTime.tryParse(p['created_at'] ?? '');
          return TableRow(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminColors.divider))),
            children: [
              _TD(p['student_name'] ?? 'Unknown'),
              _TD('₹${NumberFormat('#,##,###').format(p['amount'] ?? 0)}'),
              _TD(date != null ? DateFormat('d MMM y').format(date) : '—'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: AdminStatusBadge(
                  label: (p['status'] ?? 'pending').toUpperCase(),
                  type: p['status'] == 'success'
                      ? AdminBadgeType.success
                      : AdminBadgeType.error,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _TH(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AdminColors.textMuted)),
      );

  Widget _TD(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: AdminColors.textPrimary)),
      );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.person_add_rounded, 'Add Student', '/students'),
      (Icons.add_box_rounded, 'New Batch', '/batches'),
      (Icons.campaign_rounded, 'Announcement', '/announcements'),
      (Icons.fact_check_rounded, 'Mark Attendance', '/attendance'),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        return InkWell(
          onTap: () => context.go(a.$3),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.$1, size: 16, color: AdminColors.primaryTeal),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    a.$2,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PendingLeavesWidget extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _PendingLeavesWidget({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: count > 0
              ? const LinearGradient(
                  colors: [Color(0xFFFFF7E6), Color(0xFFFFF3CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: count == 0 ? AdminColors.surface : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: count > 0
                ? AdminColors.warning.withOpacity(0.4)
                : AdminColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: count > 0
                    ? AdminColors.warning.withOpacity(0.15)
                    : AdminColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                color: count > 0 ? AdminColors.warning : AdminColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Requests',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary),
                  ),
                  Text(
                    '$count pending review',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            count > 0 ? AdminColors.warning : AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AdminColors.warning,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
