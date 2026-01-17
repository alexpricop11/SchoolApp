import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../model/grade_model.dart';
import '../model/schedule_model.dart';
import '../model/homework_model.dart';
import '../model/attendance_model.dart';
import '../model/notification_model.dart';
import '../model/student.dart';

class StudentDataApi {
  final Dio dio;

  StudentDataApi(this.dio);

  // ==================== STUDENT ====================

  Future<StudentModel?> getMe({bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedStudent();
      if (cached != null && !CacheService.isCacheStale('student_cache')) {
        debugPrint('>>> Using cached student data');
        return StudentModel.fromJson(cached);
      }
    }

    try {
      final response = await dio.get('/students/me');
      if (response.statusCode == 200) {
        // Cache the response
        await CacheService.cacheStudent(Map<String, dynamic>.from(response.data));
        return StudentModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching current student: $e');
      // Return cached data on error
      final cached = CacheService.getCachedStudent();
      if (cached != null) {
        return StudentModel.fromJson(cached);
      }
      return null;
    }
  }

  // ==================== GRADES ====================

  Future<List<GradeModel>> getMyGrades({bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedGrades();
      if (cached != null && !CacheService.isCacheStale('grades_cache')) {
        debugPrint('>>> Using cached grades');
        return cached.map((json) => GradeModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await dio.get('/grades/my-grades');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Cache the response
        await CacheService.cacheGrades(
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        return data.map((json) => GradeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      // Return cached data on error
      final cached = CacheService.getCachedGrades();
      if (cached != null) {
        return cached.map((json) => GradeModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  // ==================== SCHEDULE ====================

  Future<List<ScheduleModel>> getClassSchedule(String classId, {bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedSchedule(classId);
      if (cached != null && !CacheService.isCacheStale('schedule_cache:$classId')) {
        debugPrint('>>> Using cached schedule');
        return cached.map((json) => ScheduleModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await dio.get('/schedules/class/$classId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Cache the response
        await CacheService.cacheSchedule(
          classId,
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      // Return cached data on error
      final cached = CacheService.getCachedSchedule(classId);
      if (cached != null) {
        return cached.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  // ==================== HOMEWORK ====================

  Future<List<HomeworkModel>> getClassHomework(String classId, {bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedHomework(classId);
      if (cached != null && !CacheService.isCacheStale('homework_cache:$classId')) {
        debugPrint('>>> Using cached homework');
        return cached.map((json) => HomeworkModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await dio.get('/homework/class/$classId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Cache the response
        await CacheService.cacheHomework(
          classId,
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        return data.map((json) => HomeworkModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching homework: $e');
      // Return cached data on error
      final cached = CacheService.getCachedHomework(classId);
      if (cached != null) {
        return cached.map((json) => HomeworkModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  // ==================== ATTENDANCE ====================

  Future<List<AttendanceModel>> getMyAttendance(String studentId, {bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedAttendance(studentId);
      if (cached != null && !CacheService.isCacheStale('attendance_cache:$studentId')) {
        debugPrint('>>> Using cached attendance');
        return cached.map((json) => AttendanceModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await dio.get('/attendance/student/$studentId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Cache the response
        await CacheService.cacheAttendance(
          studentId,
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      // Return cached data on error
      final cached = CacheService.getCachedAttendance(studentId);
      if (cached != null) {
        return cached.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  // ==================== NOTIFICATIONS ====================

  Future<List<NotificationModel>> getMyNotifications({bool forceRefresh = false}) async {
    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedNotifications();
      if (cached != null && !CacheService.isCacheStale('notifications_cache', maxAge: Duration(minutes: 5))) {
        debugPrint('>>> Using cached notifications');
        return cached.map((json) => NotificationModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await dio.get('/notifications/my-notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Cache the response
        await CacheService.cacheNotifications(
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      // Return cached data on error
      final cached = CacheService.getCachedNotifications();
      if (cached != null) {
        return cached.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await dio.put('/notifications/$notificationId/read');
      // Invalidate notifications cache
      await CacheService.clearCache('notifications_cache');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}