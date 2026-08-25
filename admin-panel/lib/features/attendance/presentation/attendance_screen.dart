import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final attendanceAdminProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
    (ref, dateStr) async {
  final data = await Supabase.instance.client
      .from('attendance')
      .select('*, profiles(full_name, student_id, batch_code)')
      .eq('date', dateStr)
      .order('created_at');
  return List<Map<String, dynamic>>.from(data);
});

final studentsForAttendanceProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('profiles')
      .select('id, full_name, student_id, batch_code')
      .eq('role', 'student')
      .order('full_name');
});

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterBatch = 'All';

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceAdminProvider(_dateStr));

    return Column(
      children: [
        AdminPageHeader(
          title: 'Attendance',
          subtitle: 'View and manage daily attendance records',
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 14),
              label: const Text('Mark Attendance'),
              onPressed: () => _showMarkDialog(context),
            ),
          ],
        ),
        // Date & Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AdminColors.surface,
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 16, color: AdminColors.textMuted),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AdminColors.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                    color: AdminColors.background,
                  ),
                  child: Text(
                    DateFormat('d MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedDate.isAfter(DateTime.now()
                        .subtract(const Duration(days: 1)))
                    ? 'Today'
                    : DateFormat('EEEE').format(_selectedDate),
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: attendanceAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString()),
            data: (records) {
              if (records.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.fact_check_rounded,
                  title: 'No attendance records for this date',
                  action: OutlinedButton(
                    onPressed: () => _showMarkDialog(context),
                    child: const Text('Mark Attendance'),
                  ),
                );
              }

              // Compute summary
              final present = records.where((r) => r['status'] == 'present').length;
              final absent = records.where((r) => r['status'] == 'absent').length;
              final leave = records.where((r) => r['status'] == 'leave').length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary row
                    Row(
                      children: [
                        _SummaryChip(label: 'Present', count: present, color: AdminColors.success),
                        const SizedBox(width: 10),
                        _SummaryChip(label: 'Absent', count: absent, color: AdminColors.error),
                        const SizedBox(width: 10),
                        _SummaryChip(label: 'Leave', count: leave, color: AdminColors.warning),
                        const SizedBox(width: 10),
                        _SummaryChip(label: 'Total', count: records.length, color: AdminColors.info),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminCard(
                      padding: EdgeInsets.zero,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                                color: AdminColors.background),
                            children: [
                              _TH('Student'), _TH('Batch'), _TH('Subject'), _TH('Status'),
                            ],
                          ),
                          ...records.map((r) {
                            final profile = r['profiles'] as Map<String, dynamic>?;
                            final status = r['status'] ?? 'absent';
                            return TableRow(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AdminColors.divider))),
                              children: [
                                _TD('${profile?['full_name'] ?? '—'}\n${profile?['student_id'] ?? ''}'),
                                _TD(profile?['batch_code'] ?? '—'),
                                _TD(r['subject'] ?? '—'),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: AdminStatusBadge(
                                    label: status.toUpperCase(),
                                    type: status == 'present'
                                        ? AdminBadgeType.success
                                        : status == 'leave'
                                            ? AdminBadgeType.warning
                                            : AdminBadgeType.error,
                                  ),
                                ),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted)));

  Widget _TD(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Text(t, style: const TextStyle(fontSize: 12, color: AdminColors.textPrimary)));

  void _showMarkDialog(BuildContext context) {
    final studentsAsync = ref.watch(studentsForAttendanceProvider);
    showDialog(
      context: context,
      builder: (_) => _MarkAttendanceDialog(
        students: studentsAsync.value ?? [],
        date: _dateStr,
        onMarked: () => ref.invalidate(attendanceAdminProvider(_dateStr)),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MarkAttendanceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final String date;
  final VoidCallback onMarked;
  const _MarkAttendanceDialog({required this.students, required this.date, required this.onMarked});

  @override
  State<_MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<_MarkAttendanceDialog> {
  final _subjectCtrl = TextEditingController();
  final Map<String, String> _statuses = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final s in widget.students) {
      _statuses[s['id']] = 'present';
    }
  }

  Future<void> _save() async {
    if (_subjectCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final records = _statuses.entries.map((e) => {
        'student_id': e.key,
        'subject': _subjectCtrl.text.trim(),
        'date': widget.date,
        'day': DateFormat('EEEE').format(DateTime.parse(widget.date)),
        'status': e.value,
      }).toList();

      await Supabase.instance.client.from('attendance').upsert(records,
          onConflict: 'student_id,date,subject');
      widget.onMarked();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mark Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject / Topic'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(flex: 3, child: Text('Student', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted))),
                const Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted))),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: widget.students.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('${s['full_name']}\n${s['student_id'] ?? ''}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: _statuses[s['id']] ?? 'present',
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'present', child: Text('Present')),
                              DropdownMenuItem(value: 'absent', child: Text('Absent')),
                              DropdownMenuItem(value: 'leave', child: Text('Leave')),
                              DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
                            ],
                            onChanged: (v) => setState(() => _statuses[s['id']] = v ?? 'present'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save (${_statuses.length})'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
