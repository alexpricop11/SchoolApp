import '../entities/teacher_entity.dart';

abstract class TeacherRepository {
  Future<List<TeacherEntity>> getTeachers();
  Future<TeacherEntity?> getTeacher(String teacherId);
  Future<TeacherEntity?> createTeacher(TeacherEntity teacher);
  Future<TeacherEntity?> updateTeacher(String teacherId, TeacherEntity teacher);
  Future<bool> deleteTeacher(String teacherId);
}