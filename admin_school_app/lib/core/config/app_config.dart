/// Application configuration for Admin App
/// Change these values based on your environment
class AppConfig {
  // Development server
  static const String devBaseUrl = 'http://10.240.0.129:8000';

  // Production server (update when deploying)
  static const String prodBaseUrl = 'https://api.yourschoolapp.com';

  // Current environment
  static const bool isProduction = false;

  // Get the current base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // API timeouts (Admin should fallback quickly to DB when server is down)
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 6);

  // Token refresh threshold
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Direct DB fallback (Admin only)
  static const String dbHost = '10.240.0.129';
  static const int dbPort = 5432;
  static const String dbName = 'school_db';
  static const String dbUser = 'postgres';
  static const String dbPassword = 'password';
  static const bool dbUseSSL = false;
}
