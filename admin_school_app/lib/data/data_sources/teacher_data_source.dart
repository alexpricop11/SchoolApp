import 'package:dio/dio.dart';
import '../models/teacher_model.dart';

class TeacherDataSource {
  final Dio dio;

  TeacherDataSource(this.dio);

  Future<List<TeacherModel>> getTeachers() async {
    try {
      final response = await dio.get('/teachers/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TeacherModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TeacherModel?> getTeacher(String teacherId) async {
    try {
      final response = await dio.get('/teachers/$teacherId');
      return TeacherModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<TeacherModel?> createTeacher(TeacherModel teacher) async {
    try {
      final response = await dio.post('/teachers/', data: teacher.toJson());
      return TeacherModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<TeacherModel?> updateTeacher(String teacherId, TeacherModel teacher) async {
    try {
      final response = await dio.put('/teachers/$teacherId', data: teacher.toJson());
      return TeacherModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteTeacher(String teacherId) async {
    try {
      await dio.delete('/teachers/$teacherId');
      return true;
    } catch (e) {
      return false;
    }
  }
}