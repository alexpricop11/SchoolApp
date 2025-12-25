import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  static Future<void> saveToken(String token, String role, String userId) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
  }

  // --- Read token ---
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // --- Read role ---
  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // --- Delete token ---
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
  }
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
}
