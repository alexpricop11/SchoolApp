import 'package:dio/dio.dart';
import '../models/admin_user_model.dart';

class AdminUserDataSource {
  final Dio dio;

  AdminUserDataSource(this.dio);

  Future<List<AdminUserModel>> getUsers() async {
    try {
      final response = await dio.get('/users/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AdminUserModel?> getUser(String userId) async {
    try {
      final response = await dio.get('/users/$userId');
      return AdminUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<AdminUserModel?> createUser(AdminUserModel user) async {
    try {
      final response = await dio.post('/users/', data: user.toJson());
      return AdminUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<AdminUserModel?> updateUser(String userId, AdminUserModel user) async {
    try {
      final response = await dio.put('/users/$userId', data: user.toJson());
      return AdminUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await dio.delete('/users/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }
}
