enum AnnouncementCategory { all, academic, exams, holidays, placement }

class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final AnnouncementCategory category;
  final bool isPinned;
  final bool isRead;
  final String? attachmentName;
  final String? attachmentUrl;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.isPinned = false,
    this.isRead = false,
    this.attachmentName,
    this.attachmentUrl,
  });

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    AnnouncementCategory? category,
    bool? isPinned,
    bool? isRead,
    String? attachmentName,
    String? attachmentUrl,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead ?? this.isRead,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
