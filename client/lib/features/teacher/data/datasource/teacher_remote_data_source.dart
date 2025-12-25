import 'package:dio/dio.dart';

import '../model/teacher_model.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherModel>> getAllTeachers();

  Future<TeacherModel> getTeacherById(String id);

  Future<TeacherModel> createTeacher(TeacherModel teacher);

  Future<TeacherModel> updateTeacher(String id, TeacherModel teacher);

  Future<void> deleteTeacher(String id);
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final Dio dio;

  TeacherRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TeacherModel>> getAllTeachers() async {
    final response = await dio.get('/teachers/');
    final data = response.data as List;
    return data.map((e) => TeacherModel.fromJson(e)).toList();
  }

  @override
  Future<TeacherModel> getTeacherById(String id) async {
    final response = await dio.get('/teachers/$id');
    return TeacherModel.fromJson(response.data);
  }

  @override
  Future<TeacherModel> createTeacher(TeacherModel teacher) async {
    final response = await dio.post('/teachers/', data: teacher.toJson());
    return TeacherModel.fromJson(response.data);
  }

  @override
  Future<TeacherModel> updateTeacher(String id, TeacherModel teacher) async {
    final response = await dio.put('/teachers/$id', data: teacher.toJson());
    return TeacherModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTeacher(String id) async {
    await dio.delete('/teachers/$id');
  }
}
