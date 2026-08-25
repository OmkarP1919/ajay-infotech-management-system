import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final facultyAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('faculty')
      .select('*')
      .order('full_name');
});

class FacultyScreen extends ConsumerWidget {
  const FacultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultyAsync = ref.watch(facultyAdminProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Faculty',
          subtitle: 'Manage teaching staff and instructors',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Add Faculty'),
              onPressed: () => _showAddDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: facultyAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString(),
                onRetry: () => ref.invalidate(facultyAdminProvider)),
            data: (faculty) {
              if (faculty.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.person_pin_rounded,
                  title: 'No faculty members yet',
                  action: ElevatedButton(
                    onPressed: () => _showAddDialog(context, ref),
                    child: const Text('Add First Faculty'),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: faculty.length,
                itemBuilder: (_, i) => _FacultyCard(faculty: faculty[i],
                    onDelete: () => ref.invalidate(facultyAdminProvider)),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddFacultyDialog(
          onCreated: () => ref.invalidate(facultyAdminProvider)),
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final Map<String, dynamic> faculty;
  final VoidCallback onDelete;
  const _FacultyCard({required this.faculty, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: faculty['avatar_url'] != null
                ? NetworkImage(faculty['avatar_url'])
                : null,
            backgroundColor: AdminColors.primaryTeal,
            child: faculty['avatar_url'] == null
                ? Text(
                    (faculty['full_name'] ?? 'F').substring(0, 1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            faculty['full_name'] ?? '—',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            faculty['specialization'] ?? '—',
            style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdminStatusBadge(
                label: faculty['is_active'] == true ? 'ACTIVE' : 'INACTIVE',
                type: faculty['is_active'] == true
                    ? AdminBadgeType.success
                    : AdminBadgeType.neutral,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: AdminColors.error),
                onPressed: () async {
                  await Supabase.instance.client
                      .from('faculty')
                      .delete()
                      .eq('id', faculty['id']);
                  onDelete();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddFacultyDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _AddFacultyDialog({required this.onCreated});

  @override
  State<_AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends State<_AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('faculty').insert({
        'full_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
        'phone': _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
        'specialization': _specCtrl.text.trim().isNotEmpty ? _specCtrl.text.trim() : null,
        'qualification': _qualCtrl.text.trim().isNotEmpty ? _qualCtrl.text.trim() : null,
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
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Faculty Member',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _specCtrl,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _qualCtrl,
                decoration: const InputDecoration(labelText: 'Qualification'),
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
                        : const Text('Add Faculty'),
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
