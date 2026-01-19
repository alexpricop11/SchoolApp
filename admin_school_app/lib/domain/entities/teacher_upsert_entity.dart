class TeacherUpsertEntity {
  final String? userId; // optional (server returns teacher by user_id)
  final String username;
  final String email;
  final String? subject;
  final bool isDirector;
  final bool isHomeroom;
  final String? classId;
  final String? schoolId;

  TeacherUpsertEntity({
    this.userId,
    required this.username,
    required this.email,
    this.subject,
    this.isDirector = false,
    this.isHomeroom = false,
    this.classId,
    this.schoolId,
  });
}
