class LessonModel {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final bool isCompleted;
  final bool isLocked;
  final int order;
  final String description;

  const LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.isCompleted,
    required this.isLocked,
    required this.order,
    this.description = '',
  });
}

class ModuleModel {
  final String id;
  final String title;
  final String duration;
  final List<LessonModel> lessons;
  final bool isExpanded;

  const ModuleModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.lessons,
    this.isExpanded = false,
  });
}

class ResourceModel {
  final String id;
  final String title;
  final String type; // 'PDF', 'ZIP', 'CODE'
  final String size;
  final String downloadUrl;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.downloadUrl,
  });
}

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String category;
  final String thumbnailUrl;
  final double progress; // 0.0 to 1.0
  final int totalLessons;
  final int completedLessons;
  final String activeLessonTitle;
  final List<ModuleModel> modules;
  final List<ResourceModel> resources;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    required this.thumbnailUrl,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    required this.activeLessonTitle,
    required this.modules,
    required this.resources,
  });
}
