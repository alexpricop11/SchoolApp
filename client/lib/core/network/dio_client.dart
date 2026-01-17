import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';

class DioClient {
  static Dio? _instance;

  static Future<Dio> getInstance() async {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      );

      _instance!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await SecureStorageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              options.headers['Content-Type'] = 'application/json';
              // Only log in debug mode, never log the actual token
              debugPrint('>>> Request: ${options.method} ${options.path}');
            } else {
              debugPrint('>>> No token available for: ${options.path}');
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'No token available',
                  type: DioExceptionType.cancel,
                ),
              );
            }
            return handler.next(options);
          },
          onError: (error, handler) async {
            debugPrint('>>> Error: ${error.response?.statusCode} on ${error.requestOptions.path}');

            // Handle 401 - try to refresh token
            if (error.response?.statusCode == 401) {
              final refreshed = await _tryRefreshToken();
              if (refreshed) {
                // Retry the original request with new token
                final token = await SecureStorageService.getToken();
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                try {
                  final response = await _instance!.fetch(error.requestOptions);
                  return handler.resolve(response);
                } catch (e) {
                  return handler.next(error);
                }
              }
            }
            return handler.next(error);
          },
        ),
      );
    }
    return _instance!;
  }

  static Future<bool> _tryRefreshToken() async {
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
      debugPrint('>>> Token refresh failed');
    }
    return false;
  }

  static void reset() {
    _instance = null;
  }

  static String get baseUrl => AppConfig.baseUrl;
}
