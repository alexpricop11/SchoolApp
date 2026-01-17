import 'package:dio/dio.dart';
import '../../../../core/network/auth_options.dart';
import '../model/teacher_model.dart';

abstract class TeacherRemoteDataSource {
  Future<TeacherModel> getCurrentTeacher(String token);
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
}
