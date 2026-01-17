import '../../../student/data/model/student.dart';
import '../../../student/domain/entities/student_entity.dart';
import '../../domain/entities/teacher.dart';

class TeacherModel extends Teacher {
  final List<SchoolClass> classes;

  const TeacherModel({
    required super.id,
    required super.username,
    required super.email,
    super.subject,
    super.isHomeroom,
    super.isDirector,
    List<SchoolClass>? classes,
  }) : classes = classes ?? const [];

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['user_id'] ?? '',
      username: json['user']?['username'] ?? '',
      email: json['user']?['email'] ?? '',
      subject: json['subject'],
      isHomeroom: json['is_homeroom'] ?? false,
      isDirector: json['is_director'] ?? false,
      classes: json['classes'] != null
          ? (json['classes'] as List)
                .map((c) => SchoolClass.fromJson(c))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'subject': subject,
      'is_homeroom': isHomeroom,
      'is_director': isDirector,
      'classes': classes.map((c) => c.toJson()).toList(),
    };
  }
}

class SchoolClass {
  final String id;
  final String name;
  final List<TeacherModel> teachers;
  final List<StudentModel> students;

  SchoolClass({
    required this.id,
    required this.name,
    List<TeacherModel>? teachers,
    List<StudentModel>? students,
  }) : teachers = teachers ?? const [],
       students = students ?? const [];

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      teachers: json['teachers'] != null
          ? (json['teachers'] as List)
                .map((t) => TeacherModel.fromJson(t))
                .toList()
          : [],
      students: json['students'] != null
          ? (json['students'] as List)
                .map((s) => StudentModel.fromJson(s))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teachers': teachers.map((t) => t.toJson()).toList(),
      'students': students.map((s) => s.toJson()).toList(),
    };
  }
}
