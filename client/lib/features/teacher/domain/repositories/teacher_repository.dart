import '../entities/teacher.dart';

abstract class TeacherRepository {
  Future<List<Teacher>> getAllTeachers();

  Future<Teacher> getTeacherById(String id);

  Future<Teacher> createTeacher(Teacher teacher);

  Future<Teacher> updateTeacher(String id, Teacher teacher);

  Future<void> deleteTeacher(String id);
}
