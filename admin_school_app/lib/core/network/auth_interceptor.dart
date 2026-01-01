import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../services/secure_storage_service.dart';
import '../../presentation/pages/auth/login_page.dart';

class AuthInterceptor extends Interceptor {
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
      // Add Authorization header with Bearer token
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if error is 401 Unauthorized (token expired or invalid)
    if (err.response?.statusCode == 401) {
      // Clear stored token
      await SecureStorageService.deleteToken();

      // Redirect to login page
      getx.Get.offAll(() => const LoginPage());

      // Show error message
      getx.Get.snackbar(
        'Sesiune expirată',
        'Te rugăm să te autentifici din nou',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
    }

    return handler.next(err);
  }
}