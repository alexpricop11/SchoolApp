import '../../entities/teacher_entity.dart';
import '../../repositories/teacher_repository.dart';

class CreateTeacherUseCase {
  final TeacherRepository repository;

  CreateTeacherUseCase(this.repository);

  Future<TeacherEntity?> call(TeacherEntity teacher) async {
    return await repository.createTeacher(teacher);
  }
}