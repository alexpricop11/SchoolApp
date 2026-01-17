import '../entities/teacher.dart';

abstract class TeacherRepository {

  Future<Teacher> getCurrentTeacher(String token);

}
