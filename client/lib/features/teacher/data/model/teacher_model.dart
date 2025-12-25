import '../../domain/entities/teacher.dart';

class TeacherModel extends Teacher {
  const TeacherModel({
    required super.id,
    required super.username,
    required super.email,
    super.subject,
    super.isHomeroom,
    super.isDirector,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['user_id'],
      username: json['user']['username'],
      email: json['user']['email'],
      subject: json['subject'],
      isHomeroom: json['is_homeroom'] ?? false,
      isDirector: json['is_director'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'subject': subject,
      'is_homeroom': isHomeroom,
      'is_director': isDirector,
    };
  }
}
