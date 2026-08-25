import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final adminUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('admin_users')
      .select('*')
      .order('created_at');
});

final auditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('audit_logs')
      .select('*, admin_users(full_name, email)')
      .order('created_at', ascending: false)
      .limit(50);
});

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminUsersProvider);
    final logsAsync = ref.watch(auditLogsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Admin Management',
          subtitle: 'Manage admin accounts and view audit logs',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: const Text('Add Admin'),
              onPressed: () => _showAddAdminDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: AdminCard(
                    title: 'Admin Accounts',
                    padding: EdgeInsets.zero,
                    child: adminsAsync.when(
                      loading: () => const Padding(
                          padding: EdgeInsets.all(20),
                          child: AdminLoadingSpinner()),
                      error: (e, _) =>
                          AdminErrorState(message: e.toString()),
                      data: (admins) {
                        if (admins.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: AdminEmptyState(
                                icon: Icons.admin_panel_settings_rounded,
                                title: 'No admin accounts found'),
                          );
                        }
                        return Column(
                          children: admins.map((a) => _AdminRow(
                              admin: a,
                              onToggle: () =>
                                  ref.invalidate(adminUsersProvider))).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: AdminCard(
                    title: 'Audit Log (Last 50)',
                    padding: EdgeInsets.zero,
                    child: logsAsync.when(
                      loading: () => const Padding(
                          padding: EdgeInsets.all(20),
                          child: AdminLoadingSpinner()),
                      error: (e, _) =>
                          AdminErrorState(message: e.toString()),
                      data: (logs) {
                        if (logs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: AdminEmptyState(
                                icon: Icons.history_rounded,
                                title: 'No audit logs yet'),
                          );
                        }
                        return Column(
                          children: logs.map((l) {
                            final admin = l['admin_users'] as Map<String, dynamic>?;
                            final date = DateTime.tryParse(l['created_at'] ?? '');
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AdminColors.divider))),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AdminColors.infoBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                        Icons.security_rounded,
                                        size: 14,
                                        color: AdminColors.info),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l['action'] ?? '—',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          admin?['full_name'] ?? 'System',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AdminColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    date != null
                                        ? DateFormat('d MMM, HH:mm')
                                            .format(date)
                                        : '—',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AdminColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddAdminDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddAdminDialog(
          onCreated: () => ref.invalidate(adminUsersProvider)),
    );
  }
}

class _AdminRow extends StatelessWidget {
  final Map<String, dynamic> admin;
  final VoidCallback onToggle;
  const _AdminRow({required this.admin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = admin['is_active'] == true;
    final isSuperAdmin = admin['role'] == 'super_admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AdminColors.divider))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isSuperAdmin
                ? AdminColors.gold
                : AdminColors.primaryTeal,
            child: Text(
              (admin['full_name'] ?? 'A').substring(0, 1),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(admin['full_name'] ?? '—',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(admin['email'] ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: AdminColors.textMuted)),
              ],
            ),
          ),
          AdminStatusBadge(
            label: isSuperAdmin ? 'SUPER ADMIN' : 'ADMIN',
            type: isSuperAdmin
                ? AdminBadgeType.warning
                : AdminBadgeType.info,
          ),
          const SizedBox(width: 8),
          AdminStatusBadge(
            label: isActive ? 'ACTIVE' : 'INACTIVE',
            type: isActive ? AdminBadgeType.success : AdminBadgeType.neutral,
          ),
          const SizedBox(width: 8),
          if (!isSuperAdmin)
            Switch(
              value: isActive,
              activeColor: AdminColors.success,
              onChanged: (v) async {
                await Supabase.instance.client
                    .from('admin_users')
                    .update({'is_active': v})
                    .eq('id', admin['id']);
                onToggle();
              },
            ),
        ],
      ),
    );
  }
}

class _AddAdminDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _AddAdminDialog({required this.onCreated});

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'admin';
  bool _isLoading = false;
  String? _error;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      // Note: Creating auth user requires service_role via Edge Function in production
      // For now, use admin API (available with supabase_flutter + admin scope)
      setState(() => _error =
          'To create an admin account, go to Supabase Dashboard → Authentication → Users → Add User, then run migration 003 to grant admin_users access.');
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
              const Text('Add Admin Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AdminColors.infoBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Step 1: Create the auth account in Supabase Dashboard → Authentication → Users\n'
                  'Step 2: Copy the user UUID\n'
                  'Step 3: Run migration 003 with the UUID to grant admin access',
                  style: TextStyle(fontSize: 12, color: AdminColors.info),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
