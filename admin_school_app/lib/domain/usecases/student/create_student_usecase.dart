import '../../entities/student_entity.dart';
import '../../repositories/student_repository.dart';

class CreateStudentUseCase {
  final StudentRepository repository;

  CreateStudentUseCase(this.repository);

  Future<StudentEntity?> call(StudentEntity student) async {
    return await repository.createStudent(student);
  }
}