import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/auth_options.dart';
import '../model/teacher_model.dart';

abstract class TeacherRemoteDataSource {
  Future<TeacherModel> getCurrentTeacher(String token);
  Future<String> uploadAvatar(String userId, String token, String filePath);
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final Dio dio;

  TeacherRemoteDataSourceImpl({required this.dio});

  @override
  Future<TeacherModel> getCurrentTeacher(String token) async {
    final response = await dio.get(
      '/teachers/me',
      options: AuthOptions.bearer(token), // Token trimis în header
    );
    return TeacherModel.fromJson(response.data);
  }

  @override
  Future<String> uploadAvatar(String userId, String token, String filePath) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final options = Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });

    final response = await dio.post(
      '/users/$userId/avatar',
      data: formData,
      options: options,
    );

    // Server returns updated user; extract avatar_url
    final data = response.data;
    final avatarUrl = data['avatar_url'] ?? data['user']?['avatar_url'];
    return avatarUrl ?? '';
  }
}
