class ScheduleSlot {
  final String day;
  final String time;
  final String topic;
  final String room;
  final bool isLive;

  const ScheduleSlot({
    required this.day,
    required this.time,
    required this.topic,
    required this.room,
    this.isLive = false,
  });
}

class BatchModel {
  final String id;
  final String name;
  final String code;
  final String faculty;
  final String timing;
  final String mode; // 'Offline (Lab 3)', 'Online Live'
  final String startDate;
  final String endDate;
  final double progress;
  final int totalStudents;
  final bool isActive;
  final List<ScheduleSlot> weeklySchedule;

  const BatchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.faculty,
    required this.timing,
    required this.mode,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.totalStudents,
    required this.isActive,
    required this.weeklySchedule,
  });
}
