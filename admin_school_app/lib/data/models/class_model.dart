import '../../domain/entities/class_entity.dart';

class ClassModel extends ClassEntity {
  ClassModel({
    super.id,
    required super.name,
    required super.gradeId,
    super.teacherId,
    required super.schoolId,
    super.createdAt,
    super.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id']?.toString(),
      name: json['name'] as String,
      gradeId: json['grade_id'].toString(),
      teacherId: json['teacher_id']?.toString(),
      schoolId: json['school_id'].toString(),
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
      'name': name,
      'grade_id': gradeId,
      if (teacherId != null) 'teacher_id': teacherId,
      'school_id': schoolId,
    };
  }
}