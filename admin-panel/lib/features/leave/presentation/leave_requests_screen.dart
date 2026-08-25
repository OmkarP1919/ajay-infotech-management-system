import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final leaveRequestsAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await Supabase.instance.client
      .from('leave_requests')
      .select('*, profiles(full_name, student_id, batch_code, email)')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data);
});

class LeaveRequestsScreen extends ConsumerWidget {
  const LeaveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(leaveRequestsAdminProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Leave Requests',
          subtitle: 'Review and approve student leave applications',
        ),
        Expanded(
          child: requestsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(leaveRequestsAdminProvider)),
            data: (requests) {
              if (requests.isEmpty) {
                return const AdminEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No leave requests',
                );
              }

              final pending = requests.where((r) => r['status'] == 'pending').toList();
              final reviewed = requests.where((r) => r['status'] != 'pending').toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pending.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Text('Pending Review',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AdminColors.warningBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${pending.length}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AdminColors.warning)),
                            ),
                          ],
                        ),
                      ),
                      ...pending.map((r) => _LeaveRequestCard(
                          request: r,
                          onAction: () => ref.invalidate(leaveRequestsAdminProvider))),
                      const SizedBox(height: 20),
                    ],
                    if (reviewed.isNotEmpty) ...[
                      const Text('Reviewed',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.textSecondary)),
                      const SizedBox(height: 10),
                      ...reviewed.map((r) => _LeaveRequestCard(
                          request: r,
                          onAction: () => ref.invalidate(leaveRequestsAdminProvider))),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LeaveRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAction;
  const _LeaveRequestCard({required this.request, required this.onAction});

  @override
  State<_LeaveRequestCard> createState() => _LeaveRequestCardState();
}

class _LeaveRequestCardState extends State<_LeaveRequestCard> {
  bool _isLoading = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('leave_requests').update({
        'status': status,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.request['id']);
      widget.onAction();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.request['profiles'] as Map<String, dynamic>?;
    final status = widget.request['status'] ?? 'pending';
    final isPending = status == 'pending';
    final date = DateTime.tryParse(widget.request['leave_date'] ?? '');
    final createdAt = DateTime.tryParse(widget.request['created_at'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPending
              ? AdminColors.warning.withOpacity(0.3)
              : AdminColors.cardBorder,
        ),
        boxShadow: isPending
            ? [
                BoxShadow(
                  color: AdminColors.warning.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AdminColors.primaryTeal,
            child: Text(
              (profile?['full_name'] ?? 'S').substring(0, 1),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile?['full_name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(profile?['student_id'] ?? '',
                        style: const TextStyle(
                            fontSize: 11, color: AdminColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Leave Date: ${date != null ? DateFormat('d MMM yyyy').format(date) : '—'}',
                  style: const TextStyle(
                      fontSize: 12, color: AdminColors.textSecondary),
                ),
                Text(
                  'Reason: ${widget.request['reason'] ?? '—'}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (createdAt != null)
                  Text(
                    'Submitted: ${DateFormat('d MMM y, HH:mm').format(createdAt)}',
                    style: const TextStyle(
                        fontSize: 10, color: AdminColors.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          if (isPending) ...[
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateStatus('approved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.success,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _updateStatus('rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.error,
                          side: const BorderSide(color: AdminColors.error),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Reject',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
          ] else
            AdminStatusBadge(
              label: status.toUpperCase(),
              type: status == 'approved'
                  ? AdminBadgeType.success
                  : AdminBadgeType.error,
            ),
        ],
      ),
    );
  }
}
