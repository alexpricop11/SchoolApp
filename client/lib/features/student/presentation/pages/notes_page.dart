import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasource/student_data_api.dart';
import '../../data/model/grade_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late StudentDataApi _api;
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  Map<String, List<GradeModel>> _gradesBySubject = {};
  Map<String, double> _averageBySubject = {};

  @override
  void initState() {
    super.initState();
    _api = StudentDataApi(Dio(BaseOptions(baseUrl: baseUrl)));
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final grades = await _api.getMyGrades();
    setState(() {
      _grades = grades;
      _isLoading = false;
      _calculateStats();
    });
  }

  void _calculateStats() {
    _gradesBySubject.clear();
    _averageBySubject.clear();

    for (var grade in _grades) {
      if (!_gradesBySubject.containsKey(grade.subjectName)) {
        _gradesBySubject[grade.subjectName] = [];
      }
      _gradesBySubject[grade.subjectName]!.add(grade);
    }

    _gradesBySubject.forEach((subject, grades) {
      final sum = grades.fold(0, (sum, grade) => sum + grade.value);
      _averageBySubject[subject] = sum / grades.length;
    });
  }

  Color _getGradeColor(int value) {
    if (value >= 9) return Colors.green;
    if (value >= 7) return Colors.blue;
    if (value >= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notes_page_title'.tr),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF0B0B0D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGrades,
              child: _grades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grade, size: 64, color: Colors.white24),
                          SizedBox(height: 16),
                          Text('Nu ai note încă',
                              style: TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ..._gradesBySubject.entries.map((entry) {
                          final subject = entry.key;
                          final grades = entry.value;
                          final average = _averageBySubject[subject]!;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF1A1C20),
                                  Color(0xFF111827),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subject,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${grades.length} ${grades.length == 1 ? 'notă' : 'note'}',
                                              style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _getGradeColor(average.round()).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _getGradeColor(average.round()),
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Medie',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              average.toStringAsFixed(2),
                                              style: TextStyle(
                                                color: _getGradeColor(average.round()),
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Colors.white10, height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: grades.map((grade) {
                                      return Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: _getGradeColor(grade.value).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              grade.value.toString(),
                                              style: TextStyle(
                                                color: _getGradeColor(grade.value),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              grade.type,
                                              style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
            ),
    );
  }
}
