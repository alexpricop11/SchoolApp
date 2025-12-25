import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/di/injection.dart';
import 'core/translation/app_translations.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'features/auth/domain/entities/USER_ROLE.dart';
import 'features/student/presentation/pages/home_page.dart';
import 'features/student/presentation/pages/student_home_page.dart';
import 'features/teacher/presentation/pages/teacher_page.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final token = await SecureStorageService.getToken();
  final roleString = await SecureStorageService.getRole();
  // SecureStorageService.deleteToken();

  Widget initialPage = const WelcomePage();

  if (token != null && roleString != null) {
    final role = UserRoleExtension.fromString(roleString);
    switch (role) {
      case UserRole.teacher:
        initialPage = TeacherPage();
        break;
      case UserRole.student:
        initialPage = StudentHomePage();
        break;
      case UserRole.parent:
        // initialPage = const ParentHomePage();
        break;
      case UserRole.director:
        // initialPage = const DirectorHomePage();
        break;
    }
  }

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('ro', 'RO'),
      fallbackLocale: const Locale('en', 'US'),
      home: initialPage,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
