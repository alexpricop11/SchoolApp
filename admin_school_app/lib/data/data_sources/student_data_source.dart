import 'package:dio/dio.dart';
import '../models/student_model.dart';

class StudentDataSource {
  final Dio dio;

  StudentDataSource(this.dio);

  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await dio.get('/students/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => StudentModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentModel?> getStudent(String studentId) async {
    try {
      final response = await dio.get('/students/$studentId');
      return StudentModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<StudentModel?> createStudent(StudentModel student) async {
    try {
      final response = await dio.post('/students/', data: student.toJson());
      return StudentModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<StudentModel?> updateStudent(String studentId, StudentModel student) async {
    try {
      final response = await dio.put('/students/$studentId', data: student.toJson());
      return StudentModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      await dio.delete('/students/$studentId');
      return true;
    } catch (e) {
      return false;
    }
  }
}