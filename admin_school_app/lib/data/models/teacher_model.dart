import '../../domain/entities/teacher_entity.dart';

class TeacherModel extends TeacherEntity {
  TeacherModel({
    super.id,
    required super.userId,
    required super.schoolId,
    super.specialization,
    super.createdAt,
    super.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id']?.toString(),
      userId: json['user_id'].toString(),
      schoolId: json['school_id'].toString(),
      specialization: json['specialization'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'school_id': schoolId,
      if (specialization != null) 'specialization': specialization,
    };
  }
}