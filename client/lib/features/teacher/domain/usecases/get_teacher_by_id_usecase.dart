import '../entities/teacher.dart';
import '../repositories/teacher_repository.dart';

class GetTeacherById {
  final TeacherRepository repo;

  GetTeacherById(this.repo);

  Future<Teacher> call(String id) async {
    return await repo.getTeacherById(id);
  }
}
