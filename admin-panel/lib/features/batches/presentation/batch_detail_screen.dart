import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final batchDetailAdminProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final batch = await Supabase.instance.client
      .from('batches')
      .select('*')
      .eq('id', id)
      .maybeSingle();
  if (batch == null) return null;

  final schedules = await Supabase.instance.client
      .from('batch_schedules')
      .select('*')
      .eq('batch_id', id)
      .order('day');

  final students = await Supabase.instance.client
      .from('profiles')
      .select('id, full_name, student_id, email, overall_attendance')
      .eq('batch_code', batch['code'])
      .eq('role', 'student');

  return {
    'batch': batch,
    'schedules': schedules,
    'students': students,
  };
});

class BatchDetailScreen extends ConsumerWidget {
  final String batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(batchDetailAdminProvider(batchId));

    return dataAsync.when(
      loading: () => const Scaffold(body: AdminLoadingSpinner()),
      error: (e, _) => Scaffold(body: AdminErrorState(message: e.toString())),
      data: (data) {
        if (data == null) {
          return Scaffold(
            body: AdminEmptyState(
              icon: Icons.school_outlined,
              title: 'Batch not found',
              action: ElevatedButton(
                onPressed: () => context.go('/batches'),
                child: const Text('Back to Batches'),
              ),
            ),
          );
        }

        final batch = data['batch'] as Map<String, dynamic>;
        final schedules =
            List<Map<String, dynamic>>.from(data['schedules'] ?? []);
        final students =
            List<Map<String, dynamic>>.from(data['students'] ?? []);

        return Column(
          children: [
            AdminPageHeader(
              title: '${batch['code']} — ${batch['name']}',
              subtitle: 'Faculty: ${batch['faculty'] ?? '—'} · ${batch['timing'] ?? ''}',
              actions: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded, size: 14),
                  label: const Text('Back'),
                  onPressed: () => context.go('/batches'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          AdminCard(
                            title: 'Batch Schedule',
                            child: schedules.isEmpty
                                ? const AdminEmptyState(
                                    icon: Icons.schedule_rounded,
                                    title: 'No schedule configured')
                                : Column(
                                    children: schedules.map((s) {
                                      return ListTile(
                                        dense: true,
                                        title: Text('${s['day']}: ${s['topic'] ?? ''}',
                                            style: const TextStyle(fontSize: 13)),
                                        subtitle: Text('${s['time']} · ${s['room'] ?? ''}',
                                            style: const TextStyle(fontSize: 11)),
                                        trailing: s['is_live'] == true
                                            ? const AdminStatusBadge(
                                                label: 'LIVE',
                                                type: AdminBadgeType.success)
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          AdminCard(
                            title: 'Batch Info',
                            child: Column(
                              children: [
                                _InfoRow('Start Date', batch['start_date'] ?? '—'),
                                _InfoRow('End Date', batch['end_date'] ?? '—'),
                                _InfoRow('Mode', batch['mode'] ?? '—'),
                                _InfoRow('Students', '${batch['total_students'] ?? 0}'),
                                _InfoRow('Progress',
                                    '${(batch['progress'] as num? ?? 0).toStringAsFixed(0)}%'),
                                _InfoRow('Status',
                                    batch['is_active'] == true ? 'Active' : 'Closed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: AdminCard(
                        title: 'Students (${students.length})',
                        padding: EdgeInsets.zero,
                        child: students.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: AdminEmptyState(
                                    icon: Icons.people_outlined,
                                    title: 'No students in this batch'),
                              )
                            : Column(
                                children: students.map((s) {
                                  final att =
                                      (s['overall_attendance'] as num? ?? 0)
                                          .toDouble();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: AdminColors.divider))),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(s['full_name'] ?? '—',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600)),
                                              Text(s['student_id'] ?? '—',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AdminColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                        Text('${att.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: att >= 75
                                                    ? AdminColors.success
                                                    : AdminColors.error)),
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () =>
                                              context.go('/students/${s['id']}'),
                                          style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4)),
                                          child: const Text('View',
                                              style: TextStyle(fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
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

Widget _InfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AdminColors.textMuted)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary)),
        ),
      ],
    ),
  );
}
