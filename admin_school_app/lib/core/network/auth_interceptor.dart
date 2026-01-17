import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import '../services/secure_storage_service.dart';
import '../config/app_config.dart';
import '../../presentation/pages/auth/login_page.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    // Get token from secure storage
    final token = await SecureStorageService.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('>>> Request: ${options.method} ${options.path}');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('>>> Error: ${err.response?.statusCode} on ${err.requestOptions.path}');

    // Check if error is 401 Unauthorized (token expired or invalid)
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        // Try to refresh the token
        final refreshed = await _tryRefreshToken();
        _isRefreshing = false;

        if (refreshed) {
          // Retry the original request with new token
          final token = await SecureStorageService.getToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        _isRefreshing = false;
        debugPrint('Token refresh failed: $e');
      }

      // If refresh failed, logout and redirect to login
      await SecureStorageService.deleteToken();
      getx.Get.offAll(() => const LoginPage());
      getx.Get.snackbar(
        'Sesiune expirată',
        'Te rugăm să te autentifici din nou',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
    }

    return handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        final role = await SecureStorageService.getRole();
        final userId = await SecureStorageService.getUserId();

        await SecureStorageService.saveToken(newAccessToken, role ?? '', userId ?? '');
        await SecureStorageService.saveRefreshToken(newRefreshToken);
        return true;
      }
    } catch (e) {
      debugPrint('>>> Token refresh failed: $e');
    }
    return false;
  }
}