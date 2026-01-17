import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../student/data/model/student.dart';
import '../../data/model/teacher_model.dart';
import '../controllers/teacher_dashboard_controller.dart';

class ClassDetailsPage extends StatelessWidget {
  final SchoolClass schoolClass;
  final TeacherDashboardController controller;

  const ClassDetailsPage({
    super.key,
    required this.schoolClass,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schoolClass.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${schoolClass.students.length} elevi',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Opțiuni adiționale
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Acțiuni rapide pentru toată clasa
          _buildQuickActions(context),

          // Lista de elevi
          Expanded(
            child: schoolClass.students.isEmpty
                ? _buildEmptyState()
                : _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1F26),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Adaugă Temă',
              Icons.home_work_outlined,
              Colors.blue,
              () => _showAddHomeworkDialog(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Prezență',
              Icons.check_circle_outline,
              Colors.orange,
              () => _showAttendanceDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schoolClass.students.length,
      itemBuilder: (context, index) {
        final student = schoolClass.students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar elev
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: Text(
                  student.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nume elev
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      student.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Buton acțiuni
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                color: const Color(0xFF2C3E50),
                onSelected: (value) {
                  switch (value) {
                    case 'note':
                      _showAddGradeDialog(student);
                      break;
                    case 'absence':
                      _showMarkAbsenceDialog(student);
                      break;
                    case 'details':
                      _showStudentDetails(student);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'note',
                    child: Row(
                      children: [
                        Icon(Icons.grade, color: Colors.green, size: 20),
                        SizedBox(width: 12),
                        Text('Pune notă', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'absence',
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Text('Marchează absență', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('Vezi detalii', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Butoane rapide
          Row(
            children: [
              Expanded(
                child: _buildQuickActionBtn(
                  'Notă',
                  Icons.add_circle_outline,
                  Colors.green,
                  () => _showAddGradeDialog(student),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionBtn(
                  'Absență',
                  Icons.close,
                  Colors.red,
                  () => _showMarkAbsenceDialog(student),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Nu sunt elevi în această clasă',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Dialoguri pentru acțiuni
  void _showAddGradeDialog(StudentModel student) {
    final gradeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: Text(
          'Adaugă notă - ${student.username}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: gradeController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Notă (2-10)',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Anulează', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              final grade = int.tryParse(gradeController.text);
              if (grade != null && grade >= 2 && grade <= 10) {
                Get.back();
                Get.snackbar(
                  'Succes',
                  'Nota $grade a fost adăugată pentru ${student.username}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Eroare',
                  'Nota trebuie să fie între 2 și 10',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
  }

  void _showMarkAbsenceDialog(StudentModel student) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: Text(
          'Marchează absență - ${student.username}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          'Confirmă absența pentru acest elev?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Anulează', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Succes',
                'Absența a fost marcată pentru ${student.username}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Confirmă'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(StudentModel student) {
    Get.snackbar(
      'Info',
      'Detalii elev: ${student.username}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAddHomeworkDialog(BuildContext context) {
    Get.snackbar(
      'În dezvoltare',
      'Funcția de adăugare temă va fi implementată curând',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    Get.snackbar(
      'În dezvoltare',
      'Funcția de prezență pentru toată clasa va fi implementată curând',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
