import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

// Provider
final studentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
    (ref, query) async {
  var request = Supabase.instance.client
      .from('profiles')
      .select('*')
      .eq('role', 'student')
      .order('created_at', ascending: false);

  final data = await request;
  if (query.isEmpty) return List<Map<String, dynamic>>.from(data);
  final q = query.toLowerCase();
  return List<Map<String, dynamic>>.from(data).where((s) {
    return (s['full_name'] ?? '').toLowerCase().contains(q) ||
        (s['email'] ?? '').toLowerCase().contains(q) ||
        (s['student_id'] ?? '').toLowerCase().contains(q) ||
        (s['batch_code'] ?? '').toLowerCase().contains(q);
  }).toList();
});

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider(_query));

    return Column(
      children: [
        AdminPageHeader(
          title: 'Students',
          subtitle: 'Manage all enrolled students',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Add Student'),
              onPressed: () => _showAddStudentDialog(context),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  controller: _searchController,
                  hint: 'Search by name, email, ID or batch...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: studentsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(studentsProvider(_query))),
            data: (students) {
              if (students.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.people_rounded,
                  title: _query.isEmpty
                      ? 'No students found'
                      : 'No students match "$_query"',
                  subtitle: _query.isEmpty ? 'Add students to get started' : null,
                );
              }
              return _StudentsTable(
                  students: students,
                  onTap: (id) => context.go('/students/$id'));
            },
          ),
        ),
      ],
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddStudentDialog(),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final void Function(String id) onTap;
  const _StudentsTable({required this.students, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            4: FlexColumnWidth(1.5),
            5: FixedColumnWidth(80),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              children: [
                _TH('Student'), _TH('Email'), _TH('Batch'),
                _TH('Enrolled'), _TH('Attendance'), _TH('Actions'),
              ],
            ),
            ...students.map((s) {
              final date = DateTime.tryParse(s['enrolled_date'] ?? '');
              final attendance =
                  (s['overall_attendance'] as num? ?? 0).toDouble();
              return TableRow(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AdminColors.divider))),
                children: [
                  _NameCell(s),
                  _TD(s['email'] ?? '—'),
                  _TD(s['batch_code'] ?? '—'),
                  _TD(date != null ? DateFormat('d MMM y').format(date) : '—'),
                  _AttendanceCell(attendance),
                  _ActionCell(id: s['id'], onTap: onTap),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _TH(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Text(t,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textMuted)));

  Widget _TD(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Text(t, style: const TextStyle(fontSize: 12, color: AdminColors.textPrimary)));
}

Widget _NameCell(Map<String, dynamic> s) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: s['avatar_url'] != null
              ? NetworkImage(s['avatar_url'])
              : null,
          backgroundColor: AdminColors.primaryTeal,
          child: s['avatar_url'] == null
              ? Text(
                  (s['full_name'] ?? 'S').substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['full_name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary),
                  overflow: TextOverflow.ellipsis),
              Text(s['student_id'] ?? '',
                  style: const TextStyle(
                      fontSize: 10, color: AdminColors.textMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _AttendanceCell(double pct) {
  final color = pct >= 75 ? AdminColors.success : AdminColors.error;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: AdminColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (pct / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${pct.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget _ActionCell({required String id, required void Function(String) onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    child: TextButton(
      onPressed: () => onTap(id),
      style: TextButton.styleFrom(
          foregroundColor: AdminColors.primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
      child: const Text('View', style: TextStyle(fontSize: 12)),
    ),
  );
}

class _AddStudentDialog extends ConsumerStatefulWidget {
  const _AddStudentDialog();

  @override
  ConsumerState<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<_AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _programCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _programCtrl.dispose();
    _batchCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      // Create auth user via admin API (requires service_role — do via edge function)
      // For now, use signUp which creates a new account
      final res = await Supabase.instance.client.auth.admin.createUser(
        AdminUserAttributes(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          emailConfirm: true,
        ),
      );
      if (res.user == null) throw Exception('Failed to create auth user');

      final uid = res.user!.id;
      final studentId = 'AI-${DateTime.now().year}-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString()}';

      await Supabase.instance.client.from('profiles').insert({
        'id': uid,
        'student_id': studentId,
        'full_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'program': _programCtrl.text.trim(),
        'batch_code': _batchCtrl.text.trim(),
        'role': 'student',
        'enrolled_date': DateTime.now().toIso8601String().substring(0, 10),
        'overall_attendance': 0.0,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student $studentId created successfully')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add New Student',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Full Name', required: true),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email Address', type: TextInputType.emailAddress, required: true),
              const SizedBox(height: 12),
              _field(_passwordCtrl, 'Initial Password', obscure: true, required: true),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_programCtrl, 'Program / Course'),
              const SizedBox(height: 12),
              _field(_batchCtrl, 'Batch Code'),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AdminColors.error, fontSize: 12)),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _create,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Student'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false,
      TextInputType type = TextInputType.text,
      bool obscure = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => v == null || v.isEmpty ? '$label is required' : null
          : null,
    );
  }
}
