import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        AdminPageHeader(
          title: 'Notifications',
          subtitle: 'System notifications and admin alerts',
        ),
        Expanded(
          child: Center(
            child: AdminCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 48, color: AdminColors.textMuted),
                  SizedBox(height: 16),
                  Text('Notifications Coming Soon',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text(
                    'Push notification configuration will be available here.\n'
                    'You can use FCM or Supabase Realtime subscriptions.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
