import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents();
  Future<StudentEntity?> getStudent(String studentId);
  Future<StudentEntity?> createStudent(StudentEntity student);
  Future<StudentEntity?> updateStudent(String studentId, StudentEntity student);
  Future<bool> deleteStudent(String studentId);
}