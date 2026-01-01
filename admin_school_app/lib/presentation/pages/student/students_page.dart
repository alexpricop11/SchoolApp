import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student/students_controller.dart';
import '../../widgets/main_layout.dart';
import 'student_form_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentsController());

    return MainLayout(
      currentPage: 'students',
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const StudentFormPage()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Adaugă Elev', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const CircularProgressIndicator(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Se încarcă elevii...',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.loadStudents,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reîncearcă'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F3A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nu există elevi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apasă butonul + pentru a adăuga primul elev',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadStudents,
                backgroundColor: const Color(0xFF1A1F3A),
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F3A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          const Color(0xFF8B5CF6).withOpacity(0.15),
                        ),
                        headingRowHeight: 60,
                        dataRowHeight: 65,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        dataTextStyle: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('User ID')),
                          DataColumn(label: Text('Clasă ID')),
                          DataColumn(label: Text('Acțiuni')),
                        ],
                        rows: controller.students.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(Text(student.id?.toString() ?? '-')),
                              DataCell(Text(student.userId.toString())),
                              DataCell(Text(student.classId.toString())),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                      onPressed: () => Get.to(() => StudentFormPage(studentId: student.id)),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.red, size: 16),
                                      ),
                                      onPressed: () => _showDeleteDialog(controller, student.id!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elevi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gestionare studenți înrolați',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(StudentsController controller, String studentId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirmare Ștergere',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sigur doriți să ștergeți acest elev?\nAceastă acțiune nu poate fi anulată.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Anulează', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteStudent(studentId);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Șterge', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}