import '../entities/teacher.dart';
import '../repositories/teacher_repository.dart';

class GetAllTeachersUseCase {
  final TeacherRepository repository;

  GetAllTeachersUseCase(this.repository);

  Future<List<Teacher>> call() async {
    return await repository.getAllTeachers();
  }
}

class GetTeacherByIdUseCase {
  final TeacherRepository repository;

  GetTeacherByIdUseCase(this.repository);

  Future<Teacher> call(String id) async {
    return await repository.getTeacherById(id);
  }
}

class CreateTeacherUseCase {
  final TeacherRepository repository;

  CreateTeacherUseCase(this.repository);

  Future<Teacher> call(Teacher teacher) async {
    return await repository.createTeacher(teacher);
  }
}

class UpdateTeacherUseCase {
  final TeacherRepository repository;

  UpdateTeacherUseCase(this.repository);

  Future<Teacher> call(String id, Teacher teacher) async {
    return await repository.updateTeacher(id, teacher);
  }
}

class DeleteTeacherUseCase {
  final TeacherRepository repository;

  DeleteTeacherUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteTeacher(id);
  }
}
