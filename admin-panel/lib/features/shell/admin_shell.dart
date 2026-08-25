import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/auth/auth_provider.dart';
import 'widgets/admin_sidebar.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final adminAsync = ref.watch(currentAdminProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1100;

    if (isCompact && !_sidebarCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _sidebarCollapsed = true);
      });
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          AdminSidebar(
            collapsed: _sidebarCollapsed,
            onToggle: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            adminData: adminAsync.value,
          ),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(
                  onMenuTap: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  adminData: adminAsync.value,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends ConsumerWidget {
  final VoidCallback onMenuTap;
  final Map<String, dynamic>? adminData;

  const _AdminTopBar({required this.onMenuTap, this.adminData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(
          bottom: BorderSide(color: AdminColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AdminColors.textSecondary, size: 20),
            onPressed: onMenuTap,
            tooltip: 'Toggle sidebar',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AdminColors.textSecondary, size: 20),
            onPressed: () => context.go('/notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          if (adminData != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AdminColors.headerGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  (adminData!['full_name'] as String? ?? 'A')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminData!['full_name'] ?? 'Admin',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 13),
                ),
                Text(
                  adminData!['role'] == 'super_admin' ? 'Super Admin' : 'Admin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdminColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, size: 15),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.error,
              side: const BorderSide(color: AdminColors.error, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Logout'),
        content: const Text(
            'Are you sure you want to logout of the Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) context.go('/login');
    }
  }
}
