/// Application configuration for Admin App
/// Change these values based on your environment
class AppConfig {
  // Development server
  static const String devBaseUrl = 'http://192.168.8.145:8000';

  // Production server (update when deploying)
  static const String prodBaseUrl = 'https://api.yourschoolapp.com';

  // Current environment
  static const bool isProduction = false;

  // Get the current base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // API timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Token refresh threshold
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}
