import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_dashboard_controller.dart';

class ClassesTab extends StatelessWidget {
  final TeacherDashboardController controller;

  const ClassesTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1D1E33),
            child: const Row(
              children: [
                Icon(Icons.class_, color: Colors.blueAccent, size: 28),
                SizedBox(width: 12),
                Text(
                  'Clasele mele',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.classes.isEmpty) {
                return const Center(
                  child: Text(
                    'Nu aveți clase asignate',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.classes.length,
                itemBuilder: (context, index) {
                  final schoolClass = controller.classes[index];
                  return Card(
                    color: const Color(0xFF1D1E33),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        child: Text(
                          schoolClass.name[0],
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        schoolClass.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${schoolClass.students.length} elevi',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.grey, size: 16),
                      onTap: () {
                        // Navigate to class details
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
