import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/datasource/student_data_api.dart';
import '../../data/model/schedule_model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late StudentDataApi _api;
  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;
  int _selectedDay = DateTime.now().weekday - 1;

  final List<String> _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  final List<String> _dayNames = ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă', 'Duminică'];

  @override
  void initState() {
    super.initState();
    _api = StudentDataApi(Dio(BaseOptions(baseUrl: baseUrl)));
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    // In realitate, ar trebui să obținem class_id din student data
    final classId = 'class-id-placeholder'; // TODO: Get from student data
    final schedules = await _api.getClassSchedule(classId);
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  List<ScheduleModel> _getScheduleForDay(String day) {
    return _schedules.where((s) => s.dayOfWeek == day).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  @override
  Widget build(BuildContext context) {
    final daySchedule = _getScheduleForDay(_days[_selectedDay]);

    return Scaffold(
      appBar: AppBar(
        title: Text('schedule_page_title'.tr),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF0B0B0D),
      body: Column(
        children: [
          Container(
            height: 60,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: _dayNames.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = index),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Color(0xFF1A1C20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _dayNames[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadSchedule,
                    child: daySchedule.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today, size: 64, color: Colors.white24),
                                SizedBox(height: 16),
                                Text('Nu există ore pentru această zi',
                                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: daySchedule.length,
                            itemBuilder: (context, index) {
                              final schedule = daySchedule[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1A1C20), Color(0xFF111827)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        schedule.periodNumber.toString(),
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    schedule.subjectName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        '${schedule.startTime} - ${schedule.endTime}',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      if (schedule.room != null)
                                        Text(
                                          'Sala: ${schedule.room}',
                                          style: TextStyle(color: Colors.white60, fontSize: 13),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
