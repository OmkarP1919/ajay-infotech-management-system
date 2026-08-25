enum AttendanceStatus { present, absent, holiday, leave }

class AttendanceRecord {
  final String date;
  final String day;
  final String subject;
  final AttendanceStatus status;
  final String remarks;

  const AttendanceRecord({
    required this.date,
    required this.day,
    required this.subject,
    required this.status,
    this.remarks = '',
  });
}

class SubjectAttendance {
  final String subjectName;
  final int totalClasses;
  final int attendedClasses;
  final double percentage;

  const SubjectAttendance({
    required this.subjectName,
    required this.totalClasses,
    required this.attendedClasses,
    required this.percentage,
  });
}
