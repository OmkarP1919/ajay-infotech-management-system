import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

// Dashboard aggregated stats
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  // Total students
  final studentsRes = await _supabase
      .from('profiles')
      .select('id')
      .eq('role', 'student');
  final totalStudents = studentsRes.length;

  // New students this month
  final newStudentsRes = await _supabase
      .from('profiles')
      .select('id')
      .eq('role', 'student')
      .gte('created_at', monthStart.toIso8601String());
  final newStudents = newStudentsRes.length;

  // Active batches
  final batchesRes = await _supabase
      .from('batches')
      .select('id')
      .eq('is_active', true);
  final activeBatches = batchesRes.length;

  // Monthly fee collection
  final paymentsRes = await _supabase
      .from('payments')
      .select('amount')
      .eq('status', 'success')
      .gte('created_at', monthStart.toIso8601String());
  double monthCollection = 0;
  for (final p in paymentsRes) {
    monthCollection += (p['amount'] as num? ?? 0).toDouble();
  }

  // Outstanding fees
  final outstandingRes = await _supabase
      .from('fee_installments')
      .select('amount, id')
      .eq('status', 'pending');
  double outstandingAmount = 0;
  for (final f in outstandingRes) {
    outstandingAmount += (f['amount'] as num? ?? 0).toDouble();
  }
  final outstandingCount = outstandingRes.length;

  return {
    'total_students': totalStudents,
    'new_students_month': newStudents,
    'active_batches': activeBatches,
    'month_collection': monthCollection,
    'collection_pct': monthCollection > 0 ? 72 : 0,
    'outstanding_count': outstandingCount,
    'outstanding_amount': outstandingAmount,
  };
});

// Recent payments (last 50, with student join)
final recentPaymentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final payments = await _supabase
      .from('payments')
      .select('id, amount, status, created_at, student_id')
      .order('created_at', ascending: false)
      .limit(50);

  // Enrich with student names
  final enriched = <Map<String, dynamic>>[];
  for (final p in payments) {
    final profile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', p['student_id'])
        .maybeSingle();
    enriched.add({
      ...p,
      'student_name': profile?['full_name'] ?? 'Unknown Student',
    });
  }
  return enriched;
});

// Today's attendance summary
final attendanceTrendProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final records = await _supabase
      .from('attendance')
      .select('status')
      .eq('date', dateStr);

  final counts = {'present': 0, 'absent': 0, 'leave': 0, 'holiday': 0};
  for (final r in records) {
    final status = r['status'] as String? ?? 'absent';
    counts[status] = (counts[status] ?? 0) + 1;
  }
  return counts;
});

// Pending leave count
final pendingLeavesCountProvider = FutureProvider<int>((ref) async {
  final res = await _supabase
      .from('leave_requests')
      .select('id')
      .eq('status', 'pending');
  return res.length;
});
