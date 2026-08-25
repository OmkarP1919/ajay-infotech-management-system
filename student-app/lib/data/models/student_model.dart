class StudentModel {
  final String id;
  final String registrationNo;
  final String name;
  final String email;
  final String phone;
  final String program;
  final String batchCode;
  final String avatarUrl;
  final double overallAttendance;
  final int completedModules;
  final int totalModules;
  final int pendingAssignments;
  final int upcomingTests;
  final String enrolledDate;

  const StudentModel({
    required this.id,
    required this.registrationNo,
    required this.name,
    required this.email,
    required this.phone,
    required this.program,
    required this.batchCode,
    required this.avatarUrl,
    required this.overallAttendance,
    required this.completedModules,
    required this.totalModules,
    required this.pendingAssignments,
    required this.upcomingTests,
    required this.enrolledDate,
  });

  StudentModel copyWith({
    String? id,
    String? registrationNo,
    String? name,
    String? email,
    String? phone,
    String? program,
    String? batchCode,
    String? avatarUrl,
    double? overallAttendance,
    int? completedModules,
    int? totalModules,
    int? pendingAssignments,
    int? upcomingTests,
    String? enrolledDate,
  }) {
    return StudentModel(
      id: id ?? this.id,
      registrationNo: registrationNo ?? this.registrationNo,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      program: program ?? this.program,
      batchCode: batchCode ?? this.batchCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      overallAttendance: overallAttendance ?? this.overallAttendance,
      completedModules: completedModules ?? this.completedModules,
      totalModules: totalModules ?? this.totalModules,
      pendingAssignments: pendingAssignments ?? this.pendingAssignments,
      upcomingTests: upcomingTests ?? this.upcomingTests,
      enrolledDate: enrolledDate ?? this.enrolledDate,
    );
  }
}
