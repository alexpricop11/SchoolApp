class TeacherEntity {
  final String? id;
  final String userId;
  final String schoolId;
  final String? specialization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeacherEntity({
    this.id,
    required this.userId,
    required this.schoolId,
    this.specialization,
    this.createdAt,
    this.updatedAt,
  });
}