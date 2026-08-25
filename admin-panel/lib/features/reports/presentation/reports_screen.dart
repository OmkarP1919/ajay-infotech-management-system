import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final reportsDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();

  // Monthly payment data for last 6 months
  final monthlyPayments = <String, double>{};
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final nextMonth = DateTime(now.year, now.month - i + 1, 1);
    final label = DateFormat('MMM').format(month);
    final payments = await Supabase.instance.client
        .from('payments')
        .select('amount')
        .eq('status', 'success')
        .gte('created_at', month.toIso8601String())
        .lt('created_at', nextMonth.toIso8601String());
    double total = 0;
    for (final p in payments) {
      total += (p['amount'] as num? ?? 0).toDouble();
    }
    monthlyPayments[label] = total;
  }

  // Attendance rate per batch
  final batches = await Supabase.instance.client
      .from('batches')
      .select('id, code, name')
      .eq('is_active', true)
      .limit(6);

  final batchAttendance = <String, double>{};
  for (final b in batches) {
    final allRecords = await Supabase.instance.client
        .from('attendance')
        .select('status, profiles!inner(batch_code)')
        .eq('profiles.batch_code', b['code']);
    if (allRecords.isEmpty) {
      batchAttendance[b['code']] = 0;
    } else {
      final present = allRecords.where((r) => r['status'] == 'present').length;
      batchAttendance[b['code']] =
          (present / allRecords.length * 100).roundToDouble();
    }
  }

  // Student enrollment trend
  final enrollmentTrend = <String, int>{};
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final nextMonth = DateTime(now.year, now.month - i + 1, 1);
    final label = DateFormat('MMM').format(month);
    final enrolled = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('role', 'student')
        .gte('created_at', month.toIso8601String())
        .lt('created_at', nextMonth.toIso8601String());
    enrollmentTrend[label] = enrolled.length;
  }

  return {
    'monthly_payments': monthlyPayments,
    'batch_attendance': batchAttendance,
    'enrollment_trend': enrollmentTrend,
  };
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(reportsDataProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Reports & Analytics',
          subtitle: 'Institute-wide performance metrics',
        ),
        Expanded(
          child: dataAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(reportsDataProvider)),
            data: (data) {
              final monthly = data['monthly_payments'] as Map<String, double>;
              final batchAtt = data['batch_attendance'] as Map<String, double>;
              final enrollment =
                  data['enrollment_trend'] as Map<String, int>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: AdminCard(
                            title: 'Monthly Fee Collection (₹)',
                            child: SizedBox(
                              height: 220,
                              child: monthly.isEmpty
                                  ? const AdminEmptyState(
                                      icon: Icons.bar_chart_rounded,
                                      title: 'No data')
                                  : BarChart(
                                      _buildBarChart(monthly, AdminColors.primaryTeal),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: AdminCard(
                            title: 'New Enrollments per Month',
                            child: SizedBox(
                              height: 220,
                              child: enrollment.isEmpty
                                  ? const AdminEmptyState(
                                      icon: Icons.people_rounded,
                                      title: 'No data')
                                  : BarChart(
                                      _buildBarChart(
                                        enrollment.map(
                                            (k, v) => MapEntry(k, v.toDouble())),
                                        AdminColors.gold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AdminCard(
                      title: 'Attendance Rate by Batch (%)',
                      child: SizedBox(
                        height: 220,
                        child: batchAtt.isEmpty
                            ? const AdminEmptyState(
                                icon: Icons.fact_check_rounded,
                                title: 'No attendance data')
                            : BarChart(_buildBarChart(batchAtt, AdminColors.success)),
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

  BarChartData _buildBarChart(Map<String, double> data, Color color) {
    final entries = data.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY.isNaN || maxY == 0 ? 100 : maxY,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, meta) {
              final idx = val.toInt();
              if (idx < 0 || idx >= entries.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(entries[idx].key,
                    style: const TextStyle(
                        fontSize: 10, color: AdminColors.textMuted)),
              );
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(
        entries.length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value,
              color: color,
              width: 22,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
