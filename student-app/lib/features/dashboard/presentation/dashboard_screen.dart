import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/repositories/app_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentProfileProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: () async {
            ref.invalidate(studentProfileProvider);
            ref.invalidate(coursesProvider);
            ref.invalidate(announcementsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                studentAsync.when(
                  data: (student) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryTeal.withOpacity(0.2),
                                width: 2,
                              ),
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Center(
                              child: Text(
                                student.name.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.greetingPrefix} ${student.name.split(' ').first}',
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDarkest,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryTeal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  student.batchCode,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Badge(
                            smallSize: 8,
                            backgroundColor: AppColors.goldenOrange,
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                        onPressed: () => context.push('/announcements'),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(height: 54),
                  error: (_, __) => const SizedBox(height: 54),
                ),
                const SizedBox(height: 20),

                // Live Class / Today's Schedule Card (Hero Glass Card)
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(20),
                  surfaceColor: AppColors.primaryTeal,
                  isDark: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldenOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryDarkest,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.liveNow,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryDarkest,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '7:00 PM - 9:00 PM',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'RESTful API Security & Token Refresh',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: Ajay Sir • Hybrid Room 3',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GlassButton(
                        text: AppStrings.joinClassroom,
                        variant: GlassButtonVariant.accent,
                        leadingIcon: Icons.videocam_rounded,
                        height: 46,
                        borderRadius: 14,
                        onPressed: () {
                          context.push('/course-detail/crs_01');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Academic Overview Stats
                SectionHeader(
                  title: AppStrings.quickStats,
                  actionText: 'Details',
                  onActionTap: () => context.push('/attendance'),
                ),
                const SizedBox(height: 8),
                studentAsync.when(
                  data: (student) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.18,
                    children: [
                      StatCard(
                        title: 'Attendance',
                        value: '${student.overallAttendance}%',
                        subtitle: 'Good (>75%)',
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.success,
                        onTap: () => context.push('/attendance'),
                      ),
                      StatCard(
                        title: 'Completed Modules',
                        value:
                            '${student.completedModules}/${student.totalModules}',
                        subtitle: '70% Done',
                        icon: Icons.menu_book_rounded,
                        iconColor: AppColors.primaryTeal,
                        onTap: () => context.push('/courses'),
                      ),
                      StatCard(
                        title: 'Assignments',
                        value: '${student.pendingAssignments} Pending',
                        subtitle: 'Due Soon',
                        icon: Icons.assignment_outlined,
                        iconColor: AppColors.warning,
                        onTap: () => context.push('/courses'),
                      ),
                      StatCard(
                        title: 'Upcoming Tests',
                        value: '${student.upcomingTests} Scheduled',
                        subtitle: 'Sep 10',
                        icon: Icons.quiz_outlined,
                        iconColor: AppColors.primaryTeal,
                        onTap: () => context.push('/batches'),
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Continue Learning Card
                SectionHeader(
                  title: AppStrings.continueLearning,
                  actionText: AppStrings.viewAll,
                  onActionTap: () => context.push('/courses'),
                ),
                const SizedBox(height: 8),
                coursesAsync.when(
                  data: (courses) {
                    final primaryCourse = courses.first;
                    return GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(18),
                      onTap: () =>
                          context.push('/course-detail/${primaryCourse.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: AppColors.primaryTeal.withOpacity(0.1),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 28,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      primaryCourse.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDarkest,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Next: ${primaryCourse.activeLessonTitle}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primaryTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Course Progress',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${(primaryCourse.progress * 100).toInt()}% Completed',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: primaryCourse.progress,
                              minHeight: 8,
                              backgroundColor: AppColors.surfaceContainer,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Quick Action Grid (6 Tiles)
                const SectionHeader(title: AppStrings.quickActions),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    _buildQuickActionTile(
                      icon: Icons.menu_book_rounded,
                      title: 'My Courses',
                      onTap: () => context.push('/courses'),
                    ),
                    _buildQuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Batches',
                      onTap: () => context.push('/batches'),
                    ),
                    _buildQuickActionTile(
                      icon: Icons.fact_check_rounded,
                      title: 'Attendance',
                      onTap: () => context.push('/attendance'),
                    ),
                    _buildQuickActionTile(
                      icon: Icons.receipt_long_rounded,
                      title: 'Fees',
                      onTap: () => context.push('/fees'),
                    ),
                    _buildQuickActionTile(
                      icon: Icons.campaign_rounded,
                      title: 'Notices',
                      onTap: () => context.push('/announcements'),
                    ),
                    _buildQuickActionTile(
                      icon: Icons.person_rounded,
                      title: 'Profile',
                      onTap: () => context.push('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Announcements Banner Snippet
                announcementsAsync.when(
                  data: (announcements) {
                    if (announcements.isEmpty) return const SizedBox.shrink();
                    final pinned = announcements.first;
                    return GlassCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.goldenOrange.withOpacity(0.4),
                      onTap: () => context.push('/announcements'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.goldenOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.goldenOrange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'IMPORTANT',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      pinned.date,
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pinned.title,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDarkest,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      borderRadius: 18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkest,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
