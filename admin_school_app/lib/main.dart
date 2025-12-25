import 'package:admin_school_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/di/injection.dart';
import 'core/translation/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('ro', 'RO'),
      fallbackLocale: const Locale('en', 'US'),
      home: LoginPage(),
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
