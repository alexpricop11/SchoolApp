import 'package:dio/dio.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';


abstract class UserRemoteDataSource {
  Future<UserModel?> getUser();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel?> getUser() async {
    final url = '/get-current-user';
    final token = await SecureStorageService.getToken();
    if (token == null) {
      print("❌ Token not found in storage");
      return null;
    }

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      print("User load error: $e");
    }

    return null;
  }
}
