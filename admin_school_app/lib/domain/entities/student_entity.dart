class StudentEntity {
  final String? id;
  final String userId;
  final String classId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentEntity({
    this.id,
    required this.userId,
    required this.classId,
    this.createdAt,
    this.updatedAt,
  });
}