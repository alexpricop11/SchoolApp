import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  StudentModel({
    super.id,
    required super.userId,
    required super.classId,
    super.createdAt,
    super.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString(),
      userId: json['user_id'].toString(),
      classId: json['class_id'].toString(),
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
      'class_id': classId,
    };
  }
}