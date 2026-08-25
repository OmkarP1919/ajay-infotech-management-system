import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/app_repository.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceProvider);
    final subjectAsync = ref.watch(subjectAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.attendanceOverview,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primaryTeal,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Attendance Hero Gauge Card
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(22),
              surfaceColor: AppColors.primaryTeal,
              isDark: true,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 0.885,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.goldenOrange,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            '88.5%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Overall Rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.goldenOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.attendanceStanding,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    text: AppStrings.applyLeave,
                    variant: GlassButtonVariant.glass,
                    height: 44,
                    leadingIcon: Icons.send_rounded,
                    onPressed: () {
                      _showLeaveApplicationSheet(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subject-wise Breakdown
            const SectionHeader(title: 'Subject Breakdown'),
            const SizedBox(height: 8),
            subjectAsync.when(
              data: (subjects) {
                return Column(
                  children: subjects.map((subj) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subj.subjectName,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkest,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${subj.percentage}%',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: subj.percentage >= 75
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${subj.attendedClasses} of ${subj.totalClasses} classes attended',
                              style: AppTypography.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: subj.percentage / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.surfaceContainer,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  subj.percentage >= 75
                                      ? AppColors.primaryTeal
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Recent Logs List
            const SectionHeader(title: AppStrings.attendanceHistory),
            const SizedBox(height: 8),
            attendanceAsync.when(
              data: (records) {
                return Column(
                  children: records.map((rec) {
                    Color statusColor;
                    String statusText;
                    IconData statusIcon;

                    switch (rec.status) {
                      case AttendanceStatus.present:
                        statusColor = AppColors.success;
                        statusText = 'PRESENT';
                        statusIcon = Icons.check_circle_outline_rounded;
                        break;
                      case AttendanceStatus.absent:
                        statusColor = AppColors.error;
                        statusText = 'ABSENT';
                        statusIcon = Icons.highlight_off_rounded;
                        break;
                      case AttendanceStatus.holiday:
                        statusColor = AppColors.warning;
                        statusText = 'HOLIDAY';
                        statusIcon = Icons.celebration_outlined;
                        break;
                      case AttendanceStatus.leave:
                        statusColor = AppColors.info;
                        statusText = 'LEAVE';
                        statusIcon = Icons.event_busy_outlined;
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor.withOpacity(0.12),
                              ),
                              child: Icon(
                                statusIcon,
                                size: 20,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec.subject,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkest,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${rec.date} • ${rec.day}',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusText,
                                style: AppTypography.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveApplicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Apply for Leave / Regularization',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Date of Leave',
                    hintText: 'e.g. 25 Aug 2026',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason for Leave',
                    hintText: 'Explain the reason (medical, family, etc.)',
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  text: 'Submit Application',
                  variant: GlassButtonVariant.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Leave application sent to coordinator.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
