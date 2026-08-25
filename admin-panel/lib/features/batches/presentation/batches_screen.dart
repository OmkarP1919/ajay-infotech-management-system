import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final batchesAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('batches')
      .select('*')
      .order('created_at', ascending: false);
});

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesAdminProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Batches',
          subtitle: 'Manage course batches and schedules',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Batch'),
              onPressed: () => _showAddDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: batchesAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString(),
                onRetry: () => ref.invalidate(batchesAdminProvider)),
            data: (batches) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: batches.map((b) => _BatchCard(
                  batch: b,
                  onTap: () => context.go('/batches/${b['id']}'),
                )).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddBatchDialog(onCreated: () => ref.invalidate(batchesAdminProvider)),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final VoidCallback onTap;
  const _BatchCard({required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = batch['is_active'] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AdminColors.primaryTeal.withOpacity(0.3)
                : AdminColors.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch['code'] ?? '—',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.primaryTeal),
                  ),
                ),
                AdminStatusBadge(
                  label: isActive ? 'ACTIVE' : 'CLOSED',
                  type: isActive ? AdminBadgeType.success : AdminBadgeType.neutral,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(batch['name'] ?? '—',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Faculty: ${batch['faculty'] ?? '—'}',
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textMuted)),
            const SizedBox(height: 4),
            Text('Timing: ${batch['timing'] ?? '—'}',
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Mode: ${batch['mode'] ?? '—'}',
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people_rounded,
                    size: 13, color: AdminColors.textMuted),
                const SizedBox(width: 4),
                Text('${batch['total_students'] ?? 0} students',
                    style: const TextStyle(
                        fontSize: 11, color: AdminColors.textMuted)),
                const Spacer(),
                Text(
                  '${((batch['progress'] as num? ?? 0)).toStringAsFixed(0)}% complete',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primaryTeal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBatchDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _AddBatchDialog({required this.onCreated});

  @override
  State<_AddBatchDialog> createState() => _AddBatchDialogState();
}

class _AddBatchDialogState extends State<_AddBatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _timingCtrl = TextEditingController();
  final _modeCtrl = TextEditingController(text: 'Online');
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('batches').insert({
        'code': _codeCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'faculty': _facultyCtrl.text.trim(),
        'timing': _timingCtrl.text.trim(),
        'mode': _modeCtrl.text.trim(),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'end_date': DateTime.now()
            .add(const Duration(days: 180))
            .toIso8601String()
            .substring(0, 10),
        'is_active': true,
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
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
              const Text('Create New Batch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Batch Code'),
                validator: (v) =>
                    v?.isEmpty == true ? 'Batch code required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name'),
                validator: (v) =>
                    v?.isEmpty == true ? 'Batch name required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _facultyCtrl,
                decoration: const InputDecoration(labelText: 'Faculty Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timingCtrl,
                decoration:
                    const InputDecoration(labelText: 'Timing (e.g. Mon-Fri 10am-1pm)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _modeCtrl,
                decoration: const InputDecoration(labelText: 'Mode (Online / Offline / Hybrid)'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
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
