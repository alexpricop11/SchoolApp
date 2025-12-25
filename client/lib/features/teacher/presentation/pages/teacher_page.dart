import 'package:SchoolApp/features/teacher/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '../models/teacher_models.dart';
import '../widgets/dashboard_body.dart';
import 'all_class_page.dart';
import 'class_page.dart';
import 'package:SchoolApp/features/teacher/presentation/controllers/teacher_controller.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.instance.get<TeacherController>();

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            Expanded(
              child: DashboardBody(
                lessons: mockLessonsToday,
                onLessonTap: (lesson) {
                  Get.to(
                    () => ClassPage(
                      className: lesson.schoolClass.name,
                      subject: lesson.schoolClass.subject,
                      totalStudents: lesson.schoolClass.students.length,
                      onStartLesson: () {
                        Get.snackbar(
                          'Lecție',
                          'S-a început lecția pentru ${lesson.schoolClass.name}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  );
                },
                onAllClassesPressed: () {
                  Get.to(() => AllClassesPage(classes: mockClasses));
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
