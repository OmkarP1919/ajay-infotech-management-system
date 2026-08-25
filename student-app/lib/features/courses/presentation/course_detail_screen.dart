import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/app_repository.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlaying = false;
  double _playbackPosition = 18.5; // minutes
  final double _totalDuration = 65.0; // minutes
  double _playbackSpeed = 1.0;
  String _activeLessonTitle = 'Building REST APIs with Express & MongoDB';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Course Experience',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.primaryTeal,
              size: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course bookmarked!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.primaryTeal,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          final course = courses.firstWhere(
            (c) => c.id == widget.courseId,
            orElse: () => courses.first,
          );

          return Column(
            children: [
              // Interactive Video Player Container
              _buildVideoPlayerSection(course),

              // Course & Lesson Header Card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LESSON 5 OF 42',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                        Text(
                          'Instructor: ${course.instructor}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _activeLessonTitle,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkest,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tab Bar (Curriculum, Notes, Discussions, Assignments)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryTeal,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryTeal,
                  indicatorWeight: 3,
                  labelStyle: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Curriculum'),
                    Tab(text: 'Notes (PDF)'),
                    Tab(text: 'Q&A'),
                    Tab(text: 'Assignments'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCurriculumTab(course),
                    _buildNotesTab(course),
                    _buildDiscussionsTab(),
                    _buildAssignmentsTab(),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildVideoPlayerSection(CourseModel course) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          colors: [Color(0xFF0F3F47), Color(0xFF05171B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Simulated Video Content Grid / Ambient Background
          Center(
            child: Icon(
              Icons.code_rounded,
              size: 72,
              color: Colors.white.withOpacity(0.15),
            ),
          ),

          // Player Controls Overlay
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top controls (Quality, Speed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<double>(
                      initialValue: _playbackSpeed,
                      onSelected: (speed) {
                        setState(() {
                          _playbackSpeed = speed;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                        const PopupMenuItem(
                            value: 1.0, child: Text('1.0x (Normal)')),
                        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '1080p HD',
                        style: TextStyle(
                          color: AppColors.goldenOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                // Center Play/Pause & Skip Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _playbackPosition = (_playbackPosition - 10 / 60)
                              .clamp(0.0, _totalDuration);
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldenOrange,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldenOrange.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.primaryDarkest,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _playbackPosition = (_playbackPosition + 10 / 60)
                              .clamp(0.0, _totalDuration);
                        });
                      },
                    ),
                  ],
                ),

                // Bottom Seek Bar & Timers
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_playbackPosition.toInt()}:${((_playbackPosition % 1) * 60).toInt().toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_totalDuration.toInt()}:00',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        activeTrackColor: AppColors.goldenOrange,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: AppColors.goldenOrange,
                      ),
                      child: Slider(
                        value: _playbackPosition,
                        min: 0,
                        max: _totalDuration,
                        onChanged: (val) {
                          setState(() {
                            _playbackPosition = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumTab(CourseModel course) {
    if (course.modules.isEmpty) {
      return const Center(child: Text('No modules available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: course.modules.length,
      itemBuilder: (context, moduleIndex) {
        final module = course.modules[moduleIndex];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: ExpansionTile(
            initiallyExpanded: moduleIndex == 2,
            shape: const Border(),
            title: Text(
              module.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              '${module.lessons.length} Lessons • ${module.duration}',
              style: AppTypography.labelSmall,
            ),
            children: module.lessons.map((lesson) {
              final isCurrent = lesson.title == _activeLessonTitle;
              return Container(
                color: isCurrent
                    ? AppColors.primaryTeal.withOpacity(0.06)
                    : Colors.transparent,
                child: ListTile(
                  dense: true,
                  onTap: lesson.isLocked
                      ? null
                      : () {
                          setState(() {
                            _activeLessonTitle = lesson.title;
                            _isPlaying = true;
                          });
                        },
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lesson.isCompleted
                          ? AppColors.success.withOpacity(0.12)
                          : (isCurrent
                              ? AppColors.primaryTeal
                              : AppColors.surfaceContainer),
                    ),
                    child: Center(
                      child: Icon(
                        lesson.isCompleted
                            ? Icons.check_rounded
                            : (isCurrent
                                ? Icons.play_arrow_rounded
                                : Icons.lock_outline_rounded),
                        size: 16,
                        color: lesson.isCompleted
                            ? AppColors.success
                            : (isCurrent ? Colors.white : AppColors.textMuted),
                      ),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? AppColors.primaryTeal
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    lesson.duration,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10.5,
                    ),
                  ),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PLAYING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(CourseModel course) {
    if (course.resources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 48,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No course notes published yet',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Instructor will upload PDF materials shortly.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: course.resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final res = course.resources[index];
        return GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  res.type == 'PDF'
                      ? Icons.picture_as_pdf_rounded
                      : Icons.folder_zip_rounded,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkest,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${res.type} Document • ${res.size}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.cloud_download_outlined,
                  color: AppColors.primaryTeal,
                ),
                tooltip: 'Download from Supabase Storage',
                onPressed: () {
                  _downloadResource(context, res);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadResource(BuildContext context, ResourceModel res) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Downloading "${res.title}" from Supabase Cloud Storage...'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Open',
          textColor: AppColors.goldenOrange,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildDiscussionsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDiscussionMessage(
                author: 'Ajay Sir (Instructor)',
                time: '2 hours ago',
                content:
                    'Remember to set proper indexes in MongoDB on frequently queried fields like email and batchCode.',
                isInstructor: true,
              ),
              const SizedBox(height: 12),
              _buildDiscussionMessage(
                author: 'Amit Verma',
                time: '5 hours ago',
                content:
                    'How do we handle JWT token expiration gracefully on Flutter client without logging the user out immediately?',
                isInstructor: false,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask a doubt to instructor...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: AppColors.primaryTeal,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question submitted!')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionMessage({
    required String author,
    required String time,
    required String content,
    required bool isInstructor,
  }) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      borderColor: isInstructor
          ? AppColors.goldenOrange.withOpacity(0.5)
          : AppColors.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isInstructor
                      ? AppColors.primaryTeal
                      : AppColors.primaryDarkest,
                ),
              ),
              Text(time, style: AppTypography.labelSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PENDING SUBMISSION',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Due: 10 Sep 2026',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Assignment 3: Secure REST API with Role-Based Access Control',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Build a full authentication module with register, login, refresh token, and admin middleware routes. Submit project archive or PDF report (Max: 10MB).',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              GlassButton(
                text: 'Submit Assignment',
                variant: GlassButtonVariant.accent,
                leadingIcon: Icons.upload_file_rounded,
                height: 46,
                onPressed: () {
                  _showAssignmentSubmissionDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignmentSubmissionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        bool isUploading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                      'Submit Assignment to Cloud Storage',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Files will be stored securely in your private assignment folder (Max 10MB). Supported formats: .pdf, .zip, .png',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded,
                              color: AppColors.primaryTeal, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assignment_3_Solution_Submission.pdf',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '2.4 MB • Ready to Upload',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isUploading) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.primaryTeal),
                            SizedBox(height: 12),
                            Text(
                              'Uploading to Supabase Storage...',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      GlassButton(
                        text: 'Upload & Confirm Submission',
                        variant: GlassButtonVariant.accent,
                        height: 48,
                        leadingIcon: Icons.cloud_upload_rounded,
                        onPressed: () async {
                          setModalState(() {
                            isUploading = true;
                          });

                          try {
                            final repo = ref.read(appRepositoryProvider);
                            // Simulated file payload for test
                            final dummyBytes =
                                List<int>.filled(1024 * 10, 65); // 10KB sample
                            await repo.submitAssignment(
                              courseId: widget.courseId,
                              assignmentTitle:
                                  'Assignment 3: Secure REST API with RBAC',
                              fileName: 'Assignment_3_Solution_Submission.pdf',
                              fileBytes: Uint8List.fromList(dummyBytes),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Assignment successfully uploaded to Supabase Cloud Storage!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() {
                              isUploading = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Upload failed: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
