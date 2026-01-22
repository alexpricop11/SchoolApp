import 'package:dio/dio.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/cache_service.dart';
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

      // Try to return cached user if available
      final cachedData = CacheService.getCachedUser();
      if (cachedData != null) {
        print("📦 Returning cached user (no token)");
        return UserModel.fromJson(cachedData);
      }
      return null;
    }

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data);

        // Cache the user data for offline access
        await CacheService.cacheUser(response.data as Map<String, dynamic>);

        return user;
      }
    } catch (e) {
      print("⚠️ User load error: $e");

      // If server is unavailable, try to return cached user
      final cachedData = CacheService.getCachedUser();
      if (cachedData != null) {
        print("📦 Server unavailable - returning cached user: ${cachedData['username']}");
        return UserModel.fromJson(cachedData);
      }
    }

    return null;
  }
}
