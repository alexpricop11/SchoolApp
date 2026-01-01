import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/teacher/teacher_form_controller.dart';

class TeacherFormPage extends StatelessWidget {
  final String? teacherId;

  const TeacherFormPage({super.key, this.teacherId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherFormController(teacherId: teacherId));

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? 'Editează Profesorul' : 'Adaugă Profesor')),
        backgroundColor: Colors.indigo,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.isEditMode.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller.userIdController,
                decoration: const InputDecoration(labelText: 'ID Utilizator *', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.schoolIdController,
                decoration: const InputDecoration(labelText: 'ID Școală *', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.specializationController,
                decoration: const InputDecoration(labelText: 'Specializare', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              if (controller.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.saveTeacher,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvează'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}