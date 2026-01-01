import 'package:get/get.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/dashboard/dashboard_page.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if migration has been performed
    final hasMigrated = await SecureStorageService.hasMigrated();

    if (!hasMigrated) {
      // First time after update - clear old tokens
      await SecureStorageService.deleteToken();
      await SecureStorageService.setMigrated();
      Get.offAll(() => const LoginPage());
      return;
    }

    // Check if user has a valid token
    final token = await SecureStorageService.getToken();

    if (token != null && token.isNotEmpty) {
      // Token exists, navigate to Dashboard
      Get.offAll(() => const DashboardPage());
    } else {
      // No token, navigate to Login
      Get.offAll(() => const LoginPage());
    }
  }
}