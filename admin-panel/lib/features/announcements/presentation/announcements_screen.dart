import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final announcementsAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('announcements')
      .select('*')
      .order('created_at', ascending: false);
});

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsAdminProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Announcements',
          subtitle: 'Create and manage institute notices',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Announcement'),
              onPressed: () => _showCreateDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: announcementsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString(),
                onRetry: () => ref.invalidate(announcementsAdminProvider)),
            data: (announcements) {
              if (announcements.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.campaign_rounded,
                  title: 'No announcements yet',
                  action: ElevatedButton(
                    onPressed: () => _showCreateDialog(context, ref),
                    child: const Text('Create First Announcement'),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                itemBuilder: (_, i) => _AnnouncementCard(
                  announcement: announcements[i],
                  onDelete: () {
                    ref.invalidate(announcementsAdminProvider);
                  },
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
      builder: (_) => _CreateAnnouncementDialog(
          onCreated: () => ref.invalidate(announcementsAdminProvider)),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onDelete;
  const _AnnouncementCard({required this.announcement, required this.onDelete});

  static const _categoryColors = {
    'all': AdminColors.primaryTeal,
    'academic': AdminColors.info,
    'exams': AdminColors.error,
    'placement': AdminColors.success,
    'holidays': AdminColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final category = announcement['category'] ?? 'all';
    final categoryColor =
        _categoryColors[category] ?? AdminColors.primaryTeal;
    final isPinned = announcement['is_pinned'] == true;
    final date = DateTime.tryParse(announcement['created_at'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPinned
              ? AdminColors.gold.withOpacity(0.4)
              : AdminColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isPinned) ...[
                  const Icon(Icons.push_pin_rounded,
                      size: 14, color: AdminColors.gold),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    announcement['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  date != null ? DateFormat('d MMM y').format(date) : '',
                  style: const TextStyle(
                      fontSize: 11, color: AdminColors.textMuted),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 16, color: AdminColors.textMuted),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (v) async {
                    if (v == 'delete') {
                      await Supabase.instance.client
                          .from('announcements')
                          .delete()
                          .eq('id', announcement['id']);
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Text(
              announcement['description'] ?? '',
              style: const TextStyle(
                  fontSize: 12, color: AdminColors.textSecondary, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAnnouncementDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateAnnouncementDialog({required this.onCreated});

  @override
  State<_CreateAnnouncementDialog> createState() =>
      _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<_CreateAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'all';
  bool _isPinned = false;
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('announcements').insert({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'date': DateFormat('d MMM yyyy').format(DateTime.now()),
        'is_pinned': _isPinned,
        'is_active': true,
        'publish_date': DateTime.now().toIso8601String().substring(0, 10),
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
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Announcement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Description / Content'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Students')),
                  DropdownMenuItem(value: 'academic', child: Text('Academic')),
                  DropdownMenuItem(value: 'exams', child: Text('Exams')),
                  DropdownMenuItem(value: 'placement', child: Text('Placement')),
                  DropdownMenuItem(value: 'holidays', child: Text('Holidays')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'all'),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _isPinned,
                title: const Text('Pin this announcement',
                    style: TextStyle(fontSize: 13)),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isPinned = v ?? false),
              ),
              const SizedBox(height: 16),
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
                        : const Text('Publish'),
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
