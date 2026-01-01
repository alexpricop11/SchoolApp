import 'package:dio/dio.dart';
import '../model/grade_model.dart';
import '../model/schedule_model.dart';
import '../model/homework_model.dart';
import '../model/attendance_model.dart';
import '../model/notification_model.dart';

class StudentDataApi {
  final Dio dio;

  StudentDataApi(this.dio);

  // Grades
  Future<List<GradeModel>> getMyGrades() async {
    try {
      final response = await dio.get('/grades/my-grades');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GradeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching grades: $e');
      return [];
    }
  }

  // Schedule
  Future<List<ScheduleModel>> getClassSchedule(String classId) async {
    try {
      final response = await dio.get('/schedules/class/$classId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }

  // Homework
  Future<List<HomeworkModel>> getClassHomework(String classId) async {
    try {
      final response = await dio.get('/homework/class/$classId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => HomeworkModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching homework: $e');
      return [];
    }
  }

  // Attendance
  Future<List<AttendanceModel>> getMyAttendance(String studentId) async {
    try {
      final response = await dio.get('/attendance/student/$studentId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  // Notifications
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await dio.get('/notifications/my-notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await dio.put('/notifications/$notificationId/read');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}