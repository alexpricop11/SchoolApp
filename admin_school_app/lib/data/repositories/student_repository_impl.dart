import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../data_sources/student_data_source.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentDataSource dataSource;

  StudentRepositoryImpl(this.dataSource);

  @override
  Future<List<StudentEntity>> getStudents() async {
    return await dataSource.getStudents();
  }

  @override
  Future<StudentEntity?> getStudent(String studentId) async {
    return await dataSource.getStudent(studentId);
  }

  @override
  Future<StudentEntity?> createStudent(StudentEntity student) async {
    final model = StudentModel(
      id: student.id,
      userId: student.userId,
      classId: student.classId,
    );
    return await dataSource.createStudent(model);
  }

  @override
  Future<StudentEntity?> updateStudent(String studentId, StudentEntity student) async {
    final model = StudentModel(
      id: student.id,
      userId: student.userId,
      classId: student.classId,
    );
    return await dataSource.updateStudent(studentId, model);
  }

  @override
  Future<bool> deleteStudent(String studentId) async {
    return await dataSource.deleteStudent(studentId);
  }
}