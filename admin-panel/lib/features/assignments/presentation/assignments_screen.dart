import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final assignmentsAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('assignments')
      .select('*, courses(title), batches(code, name)')
      .order('created_at', ascending: false);
});

final assignmentSubmissionsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
    (ref, assignmentId) async {
  return await Supabase.instance.client
      .from('assignment_submissions')
      .select('*, profiles(full_name, student_id)')
      .eq('assignment_id', assignmentId)
      .order('submitted_at', ascending: false);
});

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsAdminProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Assignments',
          subtitle: 'Create and grade student assignments',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Create Assignment'),
              onPressed: () => _showCreateDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: assignmentsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString()),
            data: (assignments) {
              if (assignments.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.assignment_rounded,
                  title: 'No assignments created yet',
                  action: ElevatedButton(
                    onPressed: () => _showCreateDialog(context, ref),
                    child: const Text('Create First Assignment'),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: assignments.map((a) {
                    return _AssignmentExpansionCard(assignment: a);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateAssignmentDialog(
          onCreated: () => ref.invalidate(assignmentsAdminProvider)),
    );
  }
}

class _AssignmentExpansionCard extends ConsumerWidget {
  final Map<String, dynamic> assignment;
  const _AssignmentExpansionCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = assignment['courses'] as Map<String, dynamic>?;
    final batch = assignment['batches'] as Map<String, dynamic>?;
    final deadline = DateTime.tryParse(assignment['deadline'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.cardBorder),
      ),
      child: ExpansionTile(
        title: Text(assignment['title'] ?? 'Untitled',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${course?['title'] ?? '—'} · ${batch?['code'] ?? 'All'} · '
          'Deadline: ${deadline != null ? DateFormat('d MMM y').format(deadline) : 'No deadline'}',
          style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
        ),
        children: [
          _SubmissionsList(assignmentId: assignment['id']),
        ],
      ),
    );
  }
}

class _SubmissionsList extends ConsumerWidget {
  final String assignmentId;
  const _SubmissionsList({required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(assignmentSubmissionsProvider(assignmentId));

    return submissionsAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.all(16), child: AdminLoadingSpinner()),
      error: (e, _) => AdminErrorState(message: e.toString()),
      data: (submissions) {
        if (submissions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: AdminEmptyState(
                icon: Icons.inbox_rounded, title: 'No submissions yet'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                decoration:
                    BoxDecoration(color: AdminColors.background),
                children: [
                  _TH2('Student'), _TH2('Submitted'), _TH2('Status'), _TH2('Grade'),
                ],
              ),
              ...submissions.map((s) {
                final profile = s['profiles'] as Map<String, dynamic>?;
                final date = DateTime.tryParse(s['submitted_at'] ?? '');
                return TableRow(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AdminColors.divider))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('${profile?['full_name'] ?? '—'}\n${profile?['student_id'] ?? ''}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(date != null ? DateFormat('d MMM y').format(date) : '—',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: AdminStatusBadge(
                        label: (s['status'] ?? 'submitted').toUpperCase(),
                        type: s['grade'] != null
                            ? AdminBadgeType.success
                            : AdminBadgeType.info,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(s['grade'] ?? '—',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TH2 extends StatelessWidget {
  final String text;
  const _TH2(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AdminColors.textMuted)),
      );
}

class _CreateAssignmentDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateAssignmentDialog({required this.onCreated});

  @override
  State<_CreateAssignmentDialog> createState() => _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<_CreateAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('assignments').insert({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'deadline': _deadline?.toIso8601String(),
        'is_active': true,
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Assignment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Assignment Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Instructions / Description'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(_deadline == null
                    ? 'Set Deadline (optional)'
                    : DateFormat('d MMM y').format(_deadline!)),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _create,
                    child: _isLoading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
