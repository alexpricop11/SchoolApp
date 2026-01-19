import 'package:dio/dio.dart';

/// Helpers for deciding when to fallback from HTTP to direct DB.
class NetworkFallback {
  static bool shouldFallback(Object e) {
    if (e is DioException) {
      // Network error / server unreachable / timeouts.
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown ||
          (e.response == null);
    }

    // Other errors -> be conservative: do not fallback by default.
    return false;
  }

  /// Useful debug string that doesn't often end up as "null".
  static String describe(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final msg = e.message;
      return 'DioException(type=${e.type}, status=$status, message=$msg, data=$data)';
    }
    return e.toString();
  }
}
