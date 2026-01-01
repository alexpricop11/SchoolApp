import 'package:dio/dio.dart';
import '../models/school_model.dart';

class SchoolDataSource {
  final Dio dio;

  SchoolDataSource(this.dio);

  Future<List<SchoolModel>> getSchools() async {
    try {
      final response = await dio.get('/schools/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SchoolModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SchoolModel?> getSchool(String schoolId) async {
    try {
      final response = await dio.get('/schools/$schoolId');
      return SchoolModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<SchoolModel?> createSchool(SchoolModel school) async {
    try {
      final response = await dio.post('/schools/', data: school.toJson());
      return SchoolModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<SchoolModel?> updateSchool(String schoolId, SchoolModel school) async {
    try {
      final response = await dio.put('/schools/$schoolId', data: school.toJson());
      return SchoolModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteSchool(String schoolId) async {
    try {
      await dio.delete('/schools/$schoolId');
      return true;
    } catch (e) {
      return false;
    }
  }
}