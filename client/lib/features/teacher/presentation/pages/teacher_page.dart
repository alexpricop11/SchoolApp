import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_dashboard_controller.dart';
import '../widgets/home_tab_final.dart';
import '../widgets/profile_tab.dart';
import '../widgets/classes_tab.dart';
import '../widgets/teacher_schedule_page.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  'Se încarcă...',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        final List<Widget> pages = [
          HomeTabFinal(controller: controller),
          ClassesTab(controller: controller),
          TeacherSchedulePage(controller: controller),
          ProfileTab(controller: controller),
        ];

        return pages[controller.currentIndex.value];
      }),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.currentIndex.value = index,
          backgroundColor: const Color(0xFF1A1F26),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 24),
              activeIcon: Icon(Icons.home_rounded, size: 26),
              label: 'Acasă',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_, size: 24),
              activeIcon: Icon(Icons.class_, size: 26),
              label: 'Clase',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded, size: 24),
              activeIcon: Icon(Icons.calendar_today_rounded, size: 26),
              label: 'Orar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              activeIcon: Icon(Icons.person_rounded, size: 26),
              label: 'Profil',
            ),
          ],
        ),
      )),
    );
  }
}
