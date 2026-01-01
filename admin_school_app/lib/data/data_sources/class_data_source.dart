import 'package:dio/dio.dart';
import '../models/class_model.dart';

class ClassDataSource {
  final Dio dio;

  ClassDataSource(this.dio);

  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await dio.get('/classes/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ClassModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ClassModel?> getClass(String classId) async {
    try {
      final response = await dio.get('/classes/$classId');
      return ClassModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<ClassModel?> createClass(ClassModel classModel) async {
    try {
      final response = await dio.post('/classes/', data: classModel.toJson());
      return ClassModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<ClassModel?> updateClass(String classId, ClassModel classModel) async {
    try {
      final response = await dio.put('/classes/$classId', data: classModel.toJson());
      return ClassModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteClass(String classId) async {
    try {
      await dio.delete('/classes/$classId');
      return true;
    } catch (e) {
      return false;
    }
  }
}