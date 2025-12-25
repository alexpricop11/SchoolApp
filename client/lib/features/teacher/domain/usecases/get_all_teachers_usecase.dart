import '../entities/teacher.dart';
import '../repositories/teacher_repository.dart';

class GetAllTeachersUseCase {
  final TeacherRepository repo;

  GetAllTeachersUseCase(this.repo);

  Future<List<Teacher>> call() async {
    return await repo.getAllTeachers();
  }
}
