import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../student/data/model/student.dart';
import '../../data/model/teacher_model.dart';
import '../controllers/teacher_dashboard_controller.dart';

class StudentsCatalog extends StatefulWidget {
  final SchoolClass schoolClass;
  final TeacherDashboardController controller;

  const StudentsCatalog({
    super.key,
    required this.schoolClass,
    required this.controller,
  });

  @override
  State<StudentsCatalog> createState() => _StudentsCatalogState();
}

class _StudentsCatalogState extends State<StudentsCatalog> {
  late TextEditingController _searchController;
  final List<StudentModel> _selectedStudents = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    List<StudentModel> students = List.from(widget.schoolClass.students);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      students = students
          .where(
            (student) =>
                student.username.toLowerCase().contains(query) ||
                student.email.toLowerCase().contains(query),
          )
          .toList();
    }

    return students;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1F26),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1F26),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make header reactive and include AppBar here so ClassDetailsPage doesn't duplicate it
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final subjectName = widget.controller.getSubjectNameForClass(
            widget.schoolClass.id,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.schoolClass.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subjectName != null && subjectName.isNotEmpty)
                Text(
                  subjectName,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          // Header info
          _buildCompactHeader(),

          // Search bar
          _buildSearchBar(),

          // Student list
          Expanded(child: _buildStudentsList()),

          // Bulk action bar
          if (_selectedStudents.isNotEmpty) _buildBulkActionBar(),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1A1F26),
      child: Row(
        children: [
          _buildStatBadge(
            Icons.people,
            '${widget.schoolClass.students.length} elevi',
          ),
          const SizedBox(width: 12),
          _buildStatBadge(
            Icons.calendar_today,
            DateFormat('dd MMM', 'ro').format(_selectedDate),
            onTap: _selectDate,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showQuickAttendanceSheet(),
            icon: const Icon(Icons.checklist, size: 18),
            label: const Text('Prezență'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: const Color(0xFF1A1F26),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!.withOpacity(0.5)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Caută elev...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _getSubjectId() async {
    final subjectId = await widget.controller.resolveSubjectIdForClass(
      widget.schoolClass.id,
    );
    if (subjectId == null || subjectId.isEmpty) {
      Get.snackbar(
        'Eroare',
        'Nu s-a putut determina materia pentru această clasă',
      );
    }
    return subjectId;
  }

  void _showQuickAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QuickAttendanceSheet(
        students: _filteredStudents,
        selectedDate: _selectedDate,
        onSelectDate: () async {
          Navigator.pop(context);
          await _selectDate();
          _showQuickAttendanceSheet();
        },
        // Quick Attendance Sheet - Toți prezenți / Toți absenți
        onMarkAll: (status) async {
          final subjectId = await _getSubjectId();
          if (subjectId == null || subjectId.isEmpty) return;

          final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
          final baseData = {
            'status': status,
            'attendance_date': dateStr,
            'subject_id': subjectId,
          };

          bool hasSuccess = false;
          int successCount = 0;

          for (final student in _filteredStudents) {
            final id = student.userId?.trim() ?? '';
            if (id.isNotEmpty) {
              try {
                await widget.controller.markAttendanceForStudent(id, baseData);
                successCount++;
                hasSuccess = true;
              } catch (_) {
                // continuăm cu următorul elev
              }
            }
          }

          Navigator.pop(context);

          if (hasSuccess) {
            Get.snackbar(
              'Succes',
              'Prezență marcată pentru $successCount elev(i)',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },

        // Individual student in quick sheet
        onMarkStudent: (student, status) async {
          final id = student.userId?.trim() ?? '';
          if (id.isEmpty) return;

          final subjectId = await _getSubjectId();
          if (subjectId == null || subjectId.isEmpty) return;

          final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

          await widget.controller.markAttendanceForStudent(id, {
            'status': status,
            'attendance_date': dateStr,
            'subject_id': subjectId,
          });
        },
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.edit_calendar,
                color: Colors.blueAccent,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_filteredStudents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentCard(student, index);
      },
    );
  }

  Widget _buildStudentCard(StudentModel student, int index) {
    final isSelected = _selectedStudents.contains(student);
    final colors = [
      Colors.blueAccent,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];
    final avatarColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        if (_selectedStudents.isNotEmpty) {
          setState(() {
            if (isSelected) {
              _selectedStudents.remove(student);
            } else {
              _selectedStudents.add(student);
            }
          });
        }
      },
      onLongPress: () {
        setState(() {
          if (isSelected) {
            _selectedStudents.remove(student);
          } else {
            _selectedStudents.add(student);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.15)
              : const Color(0xFF1A1F26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _selectedStudents.isNotEmpty ? 40 : 0,
                child: _selectedStudents.isNotEmpty
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedStudents.add(student);
                            } else {
                              _selectedStudents.remove(student);
                            }
                          });
                        },
                        activeColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : null,
              ),

              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [avatarColor, avatarColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    // Safely get first character of username; fallback to '?' if empty
                    (student.username.isNotEmpty
                        ? student.username[0].toUpperCase()
                        : '?'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Student info
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick action buttons
              if (_selectedStudents.isEmpty) ...[
                _buildQuickAction(
                  Icons.grade,
                  Colors.orange,
                  () => _showAddGradeDialog(student),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  Icons.check_circle,
                  Colors.green,
                  () => _showQuickAttendanceDialog(student),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Nu sunt elevi în această clasă'
                : 'Niciun rezultat pentru "${_searchController.text}"',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final loading = widget.controller.isLoadingHomework.value;
                return _buildBulkButton(
                  loading ? 'Se încarcă...' : 'Temă',
                  loading ? Icons.hourglass_top : Icons.assignment,
                  Colors.blue,
                  loading ? () {} : _showBulkHomeworkDialog,
                );
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() {
                final loading = widget.controller.isLoadingAttendance.value;
                return _buildBulkButton(
                  loading ? 'Se încarcă...' : 'Prezență',
                  loading ? Icons.hourglass_top : Icons.check_circle,
                  Colors.green,
                  loading ? () {} : _showBulkAttendanceDialog,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddGradeDialog(StudentModel student) async {
    final gradeController = TextEditingController();
    String gradeType = 'other';

    String classId = widget.schoolClass.id;
    if (classId.isEmpty) {
      final alt = widget.controller.classes.firstWhereOrNull(
        (c) => c.name == widget.schoolClass.name,
      );
      if (alt != null && alt.id.isNotEmpty) {
        classId = alt.id;
      }
    }

    if (classId.isEmpty) {
      Get.snackbar(
        'Eroare',
        'Id-ul clasei este invalid. Reîmprospătează pagina și încearcă din nou.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String? subjectId = widget.controller.getSubjectIdForClass(classId);
    String? subjectName = widget.controller.getSubjectNameForClass(classId);

    if (subjectId == null) {
      await widget.controller.fetchClassSchedule(classId);
      final classSchedules = widget.controller.schedules;

      final match = classSchedules.firstWhereOrNull(
        (s) => s.teacherId == widget.controller.teacher.value?.id,
      );
      if (match != null) {
        subjectId = match.subjectId;
        subjectName ??= match.subjectName;
      } else {
        final subjects = <Map<String, String>>[];
        for (var s in classSchedules) {
          if (s.subjectId.isNotEmpty &&
              !subjects.any((e) => e['id'] == s.subjectId)) {
            subjects.add({
              'id': s.subjectId,
              'name': s.subjectName ?? 'Necunoscut',
            });
          }
        }

        if (subjects.isEmpty) {
          Get.snackbar(
            'Eroare',
            'Nu s-a găsit materia pentru această clasă. Verificați orarul.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (subjects.length == 1) {
          subjectId = subjects.first['id'];
          subjectName ??= subjects.first['name'];
        } else {
          final picked = await showDialog<String?>(
            context: context,
            builder: (context) {
              String? selected = subjects.first['id'];
              return AlertDialog(
                backgroundColor: const Color(0xFF1A1F26),
                title: const Text(
                  'Selectează materia',
                  style: TextStyle(color: Colors.white),
                ),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: subjects.map((sub) {
                        return RadioListTile<String>(
                          activeColor: Colors.blueAccent,
                          value: sub['id']!,
                          groupValue: selected,
                          onChanged: (v) => setState(() => selected = v),
                          title: Text(
                            sub['name']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text(
                      'Anulează',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, selected),
                    child: const Text('Selectează'),
                  ),
                ],
              );
            },
          );

          if (picked == null) return;
          subjectId = picked;
          subjectName = subjects.firstWhere((e) => e['id'] == picked)['name'];
        }
      }
    }

    if (subjectId == null) {
      Get.snackbar(
        'Eroare',
        'Nu s-a găsit materia pentru această clasă. Verificați orarul.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Notă pentru ${student.username}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subjectName != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.book,
                          color: Colors.blueAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subjectName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: gradeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '2-10',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF0F1419),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gradeType,
                  dropdownColor: const Color(0xFF1A1F26),
                  decoration: InputDecoration(
                    labelText: 'Tip notă',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFF0F1419),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'exam',
                      child: Text(
                        'Teză',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'test',
                      child: Text(
                        'Test',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'homework',
                      child: Text(
                        'Temă',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'assignment',
                      child: Text(
                        'Lucrare',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(
                        'Altele',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => gradeType = v ?? 'other'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Anulează',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final grade = int.tryParse(gradeController.text);
                  if (grade == null || grade < 2 || grade > 10) {
                    Get.snackbar(
                      'Eroare',
                      'Introdu o notă validă (2-10)',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final ids = [if (student.userId != null) student.userId!];
                  if (ids.isEmpty) return;

                  try {
                    // Punem await ca să așteptăm răspunsul de la server
                    await widget.controller.createGradesForStudents(ids, {
                      'value': grade,
                      'types': gradeType,
                      'subject_id': subjectId,
                    });

                    // DOAR DACĂ A REUȘIT, închidem dialogul
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    Get.snackbar(
                      'Succes',
                      'Nota a fost adăugată.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.7),
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    // Dacă e eroare (ex: timeout sau eroare server), dialogul RĂMÂNE deschis
                    Get.snackbar(
                      'Eroare',
                      'Nu s-a putut salva nota. Încearcă din nou.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text(
                  'Salvează',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBulkHomeworkDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Temă pentru ${_selectedStudents.length} elevi',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Titlu temă',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF0F1419),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descriere',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF0F1419),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Anulează', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () async {
              final ids = _selectedStudents
                  .map((s) => s.userId)
                  .whereType<String>()
                  .toList();
              await widget.controller.createHomeworkForStudents(ids, {
                'title': titleController.text,
                'description': descriptionController.text,
                'class_id': widget.schoolClass.id,
              });
              Get.back();
              _selectedStudents.clear();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Trimite', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuickAttendanceDialog(StudentModel student) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Prezență: ${student.username}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('dd MMMM yyyy', 'ro').format(_selectedDate),
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceOption(
                  'Prezent',
                  Colors.green,
                  Icons.check_circle,
                  () async {
                    final ids = [if (student.userId != null) student.userId!];
                    if (ids.isEmpty) return;
                    await widget.controller
                        .markAttendanceForStudent(student.userId ?? '', {
                          'status': 'present',
                          'attendance_date': _selectedDate.toIso8601String(),
                        });
                    Get.back();
                  },
                ),
                _buildAttendanceOption(
                  'Absent',
                  Colors.red,
                  Icons.cancel,
                  () async {
                    final ids = [if (student.userId != null) student.userId!];
                    if (ids.isEmpty) return;
                    await widget.controller
                        .markAttendanceForStudent(student.userId ?? '', {
                          'status': 'present',
                          'attendance_date': _selectedDate.toIso8601String(),
                        });
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOption(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkAttendanceDialog() {
    String status = 'present';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Prezență pentru ${_selectedStudents.length} elevi',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy', 'ro').format(_selectedDate),
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: const Color(0xFF1A1F26),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F1419),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'present',
                      child: Text(
                        'Prezent',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'absent',
                      child: Text(
                        'Absent',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => status = v ?? 'present'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Anulează',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final ids = _selectedStudents
                      .map((s) => s.userId)
                      .whereType<String>()
                      .toList();

                  // În loc de bulk, mergem unul câte unul:
                  final dateStr = _selectedDate.toIso8601String();
                  final data = {'status': status, 'attendance_date': dateStr};

                  for (final id in ids) {
                    if (id.isNotEmpty) {
                      await widget.controller.markAttendanceForStudent(
                        id,
                        data,
                      );
                    }
                  }

                  _selectedStudents.clear();
                  setState(() {});
                  Get.back();

                  Get.snackbar(
                    'Succes',
                    'Prezența a fost actualizată pentru ${_selectedStudents.length} elevi',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Salvează',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Quick Attendance Sheet Widget
class _QuickAttendanceSheet extends StatelessWidget {
  final List<StudentModel> students;
  final DateTime selectedDate;
  final VoidCallback onSelectDate;
  final Function(String status) onMarkAll;
  final Function(StudentModel student, String status) onMarkStudent;

  const _QuickAttendanceSheet({
    required this.students,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onMarkAll,
    required this.onMarkStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.checklist, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Prezență rapidă',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSelectDate,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('dd MMM', 'ro').format(selectedDate)),
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  'Toți prezenți',
                  Colors.green,
                  Icons.check_circle,
                  () => onMarkAll('present'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickButton(
                  'Toți absenți',
                  Colors.red,
                  Icons.cancel,
                  () => onMarkAll('absent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Student list (max 5 visible)
          Text(
            'Sau marchează individual:',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentAttendanceRow(student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceRow(StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF252B35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: Text(
              (student.username.isNotEmpty
                  ? student.username[0].toUpperCase()
                  : '?'),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              student.username,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildSmallButton(
            'P',
            Colors.green,
            () => onMarkStudent(student, 'present'),
          ),
          const SizedBox(width: 6),
          _buildSmallButton(
            'A',
            Colors.red,
            () => onMarkStudent(student, 'absent'),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
