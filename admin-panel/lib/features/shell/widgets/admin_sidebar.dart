import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/admin_theme.dart';

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  final bool superAdminOnly;
  const _NavItem(this.path, this.icon, this.label,
      {this.superAdminOnly = false});
}

const _navItems = [
  _NavItem('/dashboard', Icons.dashboard_rounded, 'Dashboard'),
  _NavItem('/students', Icons.people_rounded, 'Students'),
  _NavItem('/batches', Icons.school_rounded, 'Batches'),
  _NavItem('/courses', Icons.menu_book_rounded, 'Courses'),
  _NavItem('/attendance', Icons.fact_check_rounded, 'Attendance'),
  _NavItem('/leave-requests', Icons.event_busy_rounded, 'Leave Requests'),
  _NavItem('/fees', Icons.account_balance_wallet_rounded, 'Fees & Payments'),
  _NavItem('/payments', Icons.payment_rounded, 'Payments'),
  _NavItem('/announcements', Icons.campaign_rounded, 'Announcements'),
  _NavItem('/assignments', Icons.assignment_rounded, 'Assignments'),
  _NavItem('/faculty', Icons.person_pin_rounded, 'Faculty'),
  _NavItem('/reports', Icons.bar_chart_rounded, 'Reports'),
  _NavItem('/notifications', Icons.notifications_rounded, 'Notifications'),
  _NavItem('/settings', Icons.settings_rounded, 'Settings'),
  _NavItem(
    '/admin-management',
    Icons.admin_panel_settings_rounded,
    'Admin Management',
    superAdminOnly: true,
  ),
];

class AdminSidebar extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  final Map<String, dynamic>? adminData;

  const AdminSidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
    this.adminData,
  });

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = adminData?['role'] == 'super_admin';
    final currentPath = GoRouterState.of(context).matchedLocation;
    final sidebarWidth = collapsed ? 64.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AdminColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AdminColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          _SidebarHeader(collapsed: collapsed),
          const Divider(
              height: 1, color: AdminColors.sidebarBorder, thickness: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navItems.where((item) {
                if (item.superAdminOnly && !isSuperAdmin) return false;
                return true;
              }).map((item) {
                final isActive = currentPath.startsWith(item.path);
                return _NavItemTile(
                  item: item,
                  isActive: isActive,
                  collapsed: collapsed,
                  onTap: () => context.go(item.path),
                );
              }).toList(),
            ),
          ),
          const Divider(
              height: 1, color: AdminColors.sidebarBorder, thickness: 1),
          // Collapse toggle
          Tooltip(
            message: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
            child: InkWell(
              onTap: onToggle,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  collapsed
                      ? Icons.keyboard_arrow_right_rounded
                      : Icons.keyboard_arrow_left_rounded,
                  color: AdminColors.sidebarIcon,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  const _SidebarHeader({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AdminColors.goldGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajay Infotech',
                    style: const TextStyle(
                      color: AdminColors.sidebarTextActive,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AdminColors.gold.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AdminColors.sidebarActive
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: AdminColors.gold.withOpacity(0.3), width: 1)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                size: 18,
                color:
                    isActive ? AdminColors.sidebarIconActive : AdminColors.sidebarIcon,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? AdminColors.sidebarTextActive
                          : AdminColors.sidebarText,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: tile,
      );
    }
    return tile;
  }
}
