import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/repositories/app_repository.dart';

class BatchesScreen extends ConsumerStatefulWidget {
  const BatchesScreen({super.key});

  @override
  ConsumerState<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends ConsumerState<BatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Batches & Schedule',
        showBackButton: false,
        bottom: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryTeal,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryTeal,
            indicatorWeight: 3,
            labelStyle:
                AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: AppStrings.activeBatches),
              Tab(text: AppStrings.completedBatches),
            ],
          ),
        ),
        bottomHeight: kTextTabBarHeight,
      ),
      body: batchesAsync.when(
        data: (batches) {
          final activeBatches = batches.where((b) => b.isActive).toList();
          final completedBatches = batches.where((b) => !b.isActive).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBatchList(activeBatches, isActiveTab: true),
              _buildBatchList(completedBatches, isActiveTab: false),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBatchList(List batches, {required bool isActiveTab}) {
    if (batches.isEmpty) {
      return Center(
        child: Text(
          'No batches found.',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Batch Detail Card
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
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
                          color: AppColors.primaryTeal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          batch.code,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${batch.totalStudents} Students',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    batch.name,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.person_outline_rounded,
                    'Faculty',
                    batch.faculty,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.schedule_rounded,
                    'Timings',
                    batch.timing,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Location / Mode',
                    batch.mode,
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Batch Completion',
                        style: AppTypography.labelSmall,
                      ),
                      Text(
                        '${(batch.progress * 100).toInt()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: batch.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Timetable Section (if active)
            if (isActiveTab && batch.weeklySchedule.isNotEmpty) ...[
              const SectionHeader(title: 'Weekly Class Timetable'),
              const SizedBox(height: 8),
              ...batch.weeklySchedule.map<Widget>((slot) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    borderColor: slot.isLive
                        ? AppColors.goldenOrange.withOpacity(0.6)
                        : AppColors.outlineVariant,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: slot.isLive
                                ? AppColors.goldenOrange.withOpacity(0.15)
                                : AppColors.primaryTeal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                slot.day.substring(0, 3).toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: slot.isLive
                                      ? AppColors.goldenOrange
                                      : AppColors.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.topic,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDarkest,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${slot.time} • ${slot.room}',
                                style: AppTypography.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        if (slot.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldenOrange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'LIVE',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryDarkest,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primaryDarkest,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
