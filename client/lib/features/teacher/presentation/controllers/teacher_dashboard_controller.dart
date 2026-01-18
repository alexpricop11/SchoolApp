import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/datasource/teacher_remote_data_source.dart';
import '../../data/datasource/grade_remote_data_source.dart';
import '../../data/datasource/homework_remote_data_source.dart';
import '../../data/datasource/attendance_remote_data_source.dart';
import '../../data/datasource/schedule_remote_data_source.dart';
import '../../data/datasource/material_remote_data_source.dart';
import '../../data/model/teacher_model.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/entities/homework_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/material_entity.dart';
import '../../../student/data/model/student.dart';
import '../../domain/usecases/get_current_teacher.dart';

class TeacherDashboardController extends GetxController {
  // Services
  final GetCurrentTeacherUseCase getCurrentTeacherUseCase = GetIt.instance
      .get<GetCurrentTeacherUseCase>();
  final GradeRemoteDataSource gradeDataSource = GetIt.instance
      .get<GradeRemoteDataSource>();
  final HomeworkRemoteDataSource homeworkDataSource = GetIt.instance
      .get<HomeworkRemoteDataSource>();
  final AttendanceRemoteDataSource attendanceDataSource = GetIt.instance
      .get<AttendanceRemoteDataSource>();
  final ScheduleRemoteDataSource scheduleDataSource = GetIt.instance
      .get<ScheduleRemoteDataSource>();
  final MaterialRemoteDataSource materialDataSource = GetIt.instance
      .get<MaterialRemoteDataSource>();

  // Teacher data
  final teacher = Rxn<Teacher>();
  final classes = <SchoolClass>[].obs;
  final allStudents = <StudentModel>[].obs;

  // Grades
  final grades = <Grade>[].obs;
  final isLoadingGrades = false.obs;

  // Homework
  final homeworkList = <Homework>[].obs;
  final isLoadingHomework = false.obs;

  // Attendance
  final attendanceList = <Attendance>[].obs;
  final isLoadingAttendance = false.obs;

  // Schedule
  final schedules = <Schedule>[].obs;
  final isLoadingSchedule = false.obs;

  // Materials
  final materials = <Material>[].obs;
  final isLoadingMaterials = false.obs;

  // General
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentTeacher();
  }

  // ==================== TEACHER ====================
  Future<void> fetchCurrentTeacher() async {
    isLoading.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        errorMessage.value = 'No token available';
        _redirectToLogin();
        return;
      }

      final fetchedTeacher = await getCurrentTeacherUseCase.call(token);
      teacher.value = fetchedTeacher;
      classes.value = fetchedTeacher.classes ?? [];

      // Extract all students from classes
      final students = <StudentModel>[];
      for (var schoolClass in classes) {
        students.addAll(schoolClass.students);
      }
      allStudents.value = students;

      // Fetch initial data
      if (teacher.value != null) {
        await Future.wait([fetchTeacherGrades(), fetchTeacherSchedule()]);
      }
    } on DioException catch (e) {
      errorMessage.value = 'Error fetching teacher: $e';
      print('Error fetching teacher: $e');
      // Check if it's a 401 error - the interceptor should handle this
      // but if somehow it slips through, handle it here too
      if (e.response?.statusCode == 401) {
        _redirectToLogin();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching teacher: $e';
      print('Error fetching teacher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _redirectToLogin() async {
    await SecureStorageService.deleteToken();
    Get.snackbar(
      'Sesiune expirată',
      'Te rugăm să te autentifici din nou',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
    Get.offAll(() => const LoginPage());
  }

  // ==================== GRADES ====================
  Future<void> fetchTeacherGrades() async {
    if (teacher.value == null) return;

    isLoadingGrades.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedGrades = await gradeDataSource.getTeacherGrades(
        teacher.value!.id,
        token,
      );
      grades.value = fetchedGrades;
    } catch (e) {
      print('Error fetching grades: $e');
    } finally {
      isLoadingGrades.value = false;
    }
  }

  Future<void> fetchStudentGrades(String studentId) async {
    isLoadingGrades.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedGrades = await gradeDataSource.getStudentGrades(
        studentId,
        token,
      );
      grades.value = fetchedGrades;
    } catch (e) {
      print('Error fetching student grades: $e');
    } finally {
      isLoadingGrades.value = false;
    }
  }

  Future<void> createGrade(Map<String, dynamic> gradeData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // Ensure teacher_id is set
      if ((gradeData['teacher_id'] == null ||
              gradeData['teacher_id'].toString().isEmpty) &&
          teacher.value != null) {
        gradeData['teacher_id'] = teacher.value!.id;
      }

      await gradeDataSource.createGrade(gradeData, token);
      await fetchTeacherGrades();
      Get.snackbar(
        'Succes',
        'Nota a fost adăugată cu succes!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la adăugarea notei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateGrade(
    String gradeId,
    Map<String, dynamic> gradeData,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await gradeDataSource.updateGrade(gradeId, gradeData, token);
      await fetchTeacherGrades();
      Get.snackbar(
        'Succes',
        'Nota a fost actualizată!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la actualizarea notei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteGrade(String gradeId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await gradeDataSource.deleteGrade(gradeId, token);
      await fetchTeacherGrades();
      Get.snackbar(
        'Succes',
        'Nota a fost ștearsă!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la ștergerea notei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== HOMEWORK ====================
  Future<void> fetchClassHomework(String classId) async {
    isLoadingHomework.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedHomework = await homeworkDataSource.getClassHomework(
        classId,
        token,
      );
      homeworkList.value = fetchedHomework;
    } catch (e) {
      print('Error fetching homework: $e');
    } finally {
      isLoadingHomework.value = false;
    }
  }

  Future<void> createHomework(Map<String, dynamic> homeworkData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // Ensure teacher_id is set
      if ((homeworkData['teacher_id'] == null ||
              homeworkData['teacher_id'].toString().isEmpty) &&
          teacher.value != null) {
        homeworkData['teacher_id'] = teacher.value!.id;
      }

      await homeworkDataSource.createHomework(homeworkData, token);
      Get.snackbar(
        'Succes',
        'Tema a fost creată cu succes!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la crearea temei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateHomework(
    String homeworkId,
    Map<String, dynamic> homeworkData,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await homeworkDataSource.updateHomework(homeworkId, homeworkData, token);
      Get.snackbar(
        'Succes',
        'Tema a fost actualizată!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la actualizarea temei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteHomework(String homeworkId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await homeworkDataSource.deleteHomework(homeworkId, token);
      Get.snackbar(
        'Succes',
        'Tema a fost ștearsă!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la ștergerea temei: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== ATTENDANCE ====================
  Future<void> fetchStudentAttendance(String studentId) async {
    isLoadingAttendance.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedAttendance = await attendanceDataSource.getStudentAttendance(
        studentId,
        token,
      );
      attendanceList.value = fetchedAttendance;
    } catch (e) {
      print('Error fetching attendance: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  Future<void> createAttendance(Map<String, dynamic> attendanceData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // Ensure teacher_id is set
      if ((attendanceData['teacher_id'] == null ||
              attendanceData['teacher_id'].toString().isEmpty) &&
          teacher.value != null) {
        attendanceData['teacher_id'] = teacher.value!.id;
      }

      // Normalize date to ISO date (YYYY-MM-DD)
      if (attendanceData['attendance_date'] is DateTime) {
        final dt = attendanceData['attendance_date'] as DateTime;
        attendanceData['attendance_date'] = dt.toIso8601String();
      }

      await attendanceDataSource.createAttendance(attendanceData, token);
      Get.snackbar(
        'Succes',
        'Prezența a fost înregistrată!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la înregistrarea prezenței: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAttendance(
    String attendanceId,
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await attendanceDataSource.updateAttendance(
        attendanceId,
        attendanceData,
        token,
      );
      Get.snackbar(
        'Succes',
        'Prezența a fost actualizată!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la actualizarea prezenței: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== SCHEDULE ====================
  Future<void> fetchClassSchedule(String classId) async {
    if (classId.isEmpty) return; // Guard to avoid invalid requests

    isLoadingSchedule.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedSchedules = await scheduleDataSource.getClassSchedule(
        classId,
        token,
      );
      schedules.value = fetchedSchedules;
    } catch (e) {
      print('Error fetching schedule: $e');
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  Future<void> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await scheduleDataSource.createSchedule(scheduleData, token);
      Get.snackbar(
        'Succes',
        'Orarul a fost creat!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la crearea orarului: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== MATERIALS ====================
  Future<void> fetchTeacherMaterials() async {
    if (teacher.value == null) return;

    isLoadingMaterials.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedMaterials = await materialDataSource.getTeacherMaterials(
        teacher.value!.id,
        token,
      );
      materials.value = fetchedMaterials;
    } catch (e) {
      print('Error fetching materials: $e');
    } finally {
      isLoadingMaterials.value = false;
    }
  }

  // ==================== AVATAR UPLOAD ====================
  Future<void> uploadAvatar(String filePath) async {
    if (teacher.value == null) return;
    final token = await SecureStorageService.getToken();
    if (token == null) return;

    try {
      final dio = await DioClient.getInstance();
      final remote = TeacherRemoteDataSourceImpl(dio: dio);
      final avatarUrl = await remote.uploadAvatar(
        teacher.value!.id,
        token,
        filePath,
      );
      // Update local teacher object
      final updated = TeacherModel.fromJson({
        'user_id': teacher.value!.id,
        'user': {
          'username': teacher.value!.username,
          'email': teacher.value!.email,
          'avatar_url': avatarUrl,
        },
        'subject': teacher.value!.subject,
        'is_homeroom': teacher.value!.isHomeroom,
        'is_director': teacher.value!.isDirector,
        'classes':
            teacher.value!.classes?.map((c) => c.toJson()).toList() ?? [],
      });
      teacher.value = updated;
      Get.snackbar(
        'Succes',
        'Avatar actualizat cu succes!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la încărcarea avatarului: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== TEACHER SCHEDULE ====================
  final teacherSchedules = <Schedule>[].obs;
  final isLoadingTeacherSchedule = false.obs;

  Future<void> fetchTeacherSchedule() async {
    if (teacher.value == null) return;

    isLoadingTeacherSchedule.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // Directly fetch teacher's schedule from the new endpoint
      final allSchedules = await scheduleDataSource.getTeacherSchedule(
        teacher.value!.id,
        token,
      );

      // Sort by day of week and period number
      allSchedules.sort((a, b) {
        final dayOrder = a.dayOfWeek.index.compareTo(b.dayOfWeek.index);
        if (dayOrder != 0) return dayOrder;
        return a.periodNumber.compareTo(b.periodNumber);
      });

      teacherSchedules.value = allSchedules;
    } catch (e) {
      print('Error fetching teacher schedule: $e');
    } finally {
      isLoadingTeacherSchedule.value = false;
    }
  }

  DayOfWeek getTodayEnum() {
    switch (DateTime.now().weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  String getDayNameRomanian(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Luni';
      case DayOfWeek.tuesday:
        return 'Marți';
      case DayOfWeek.wednesday:
        return 'Miercuri';
      case DayOfWeek.thursday:
        return 'Joi';
      case DayOfWeek.friday:
        return 'Vineri';
      case DayOfWeek.saturday:
        return 'Sâmbătă';
      case DayOfWeek.sunday:
        return 'Duminică';
    }
  }

  List<Schedule> get todaySchedule {
    final today = getTodayEnum();
    return teacherSchedules.where((s) => s.dayOfWeek == today).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  Schedule? get nextLesson {
    final now = DateTime.now();
    final today = getTodayEnum();

    final todayLessons =
        teacherSchedules.where((s) => s.dayOfWeek == today).toList()
          ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

    for (var schedule in todayLessons) {
      final lessonTime = _parseTime(schedule.startTime);
      if (lessonTime.isAfter(now)) {
        return schedule;
      }
    }
    return null;
  }

  Schedule? get currentLesson {
    final now = DateTime.now();
    final today = getTodayEnum();

    final todayLessons =
        teacherSchedules.where((s) => s.dayOfWeek == today).toList()
          ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

    for (var schedule in todayLessons) {
      final startTime = _parseTime(schedule.startTime);
      final endTime = _parseTime(schedule.endTime);
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        return schedule;
      }
    }
    return null;
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String getTimeUntilLesson(Schedule? lesson) {
    if (lesson == null) return '';
    final lessonTime = _parseTime(lesson.startTime);
    final now = DateTime.now();
    final difference = lessonTime.difference(now);

    if (difference.isNegative) return 'Acum';
    if (difference.inMinutes < 60) {
      return 'în ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'în ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'în ${difference.inDays}z';
    }
  }

  List<Schedule> getScheduleForDay(DayOfWeek day) {
    return teacherSchedules.where((s) => s.dayOfWeek == day).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  String getClassName(String classId) {
    final schoolClass = classes.firstWhereOrNull((c) => c.id == classId);
    return schoolClass?.name ?? 'Necunoscut';
  }

  // ==================== STATISTICS ====================
  int get totalClasses => classes.length;

  int get totalStudents => allStudents.length;

  int get totalGrades => grades.length;

  int get gradesThisWeek {
    return grades.length;
  }

  int get lessonsToday => todaySchedule.length;

  // Get absences today
  int get absencesToday {
    final today = DateTime.now();
    return attendanceList
        .where(
          (att) =>
              att.attendanceDate.year == today.year &&
              att.attendanceDate.month == today.month &&
              att.attendanceDate.day == today.day &&
              att.status == AttendanceStatus.absent,
        )
        .length;
  }

  // Bulk operations for UI
  Future<void> createHomeworkForStudents(
    List<String> studentIds,
    Map<String, dynamic> homeworkData,
  ) async {
    if (teacher.value == null) return;
    isLoadingHomework.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // If bulk endpoint available, use it
      final homeworkList = studentIds.map((studentId) {
        final data = Map<String, dynamic>.from(homeworkData);
        data['student_id'] = studentId;
        data['teacher_id'] = data['teacher_id'] ?? teacher.value!.id;
        return data;
      }).toList();

      await homeworkDataSource.createHomeworkBulk(homeworkList, token);

      await fetchClassHomework(homeworkData['class_id']?.toString() ?? '');
      Get.snackbar(
        'Succes',
        'Teme create pentru ${studentIds.length} elevi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Eroare',
        'Eroare la crearea temelor: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingHomework.value = false;
    }
  }

  Future<void> markAttendanceForStudent(
    String studentId,
    Map<String, dynamic> attendanceData,
  ) async {
    print("=== markAttendanceForStudent START ===");
    print("Student ID: $studentId");
    print("Input data: $attendanceData");

    isLoadingAttendance.value = true;

    try {
      final token = await SecureStorageService.getToken();
      print("Token obtained: ${token != null ? 'YES' : 'NO'}");

      if (token == null) {
        print("No token → exiting");
        Get.snackbar('Eroare', 'Nu există token de autentificare');
        return;
      }

      final data = Map<String, dynamic>.from(attendanceData);
      data['student_id'] = studentId;
      data['teacher_id'] = data['teacher_id'] ?? teacher.value?.id;

      print("Data după adăugare student/teacher: $data");

      // Verificăm câmpurile obligatorii
      if (data['subject_id'] == null ||
          data['subject_id'].toString().trim().isEmpty) {
        throw Exception("subject_id lipsește sau e gol!");
      }
      if (data['attendance_date'] == null) {
        throw Exception("attendance_date lipsește!");
      }

      // Formatăm data foarte explicit
      final dateValue = data['attendance_date'];
      if (dateValue is DateTime) {
        data['attendance_date'] = DateFormat('yyyy-MM-dd').format(dateValue);
      } else if (dateValue is String) {
        try {
          final dt = DateTime.parse(dateValue);
          data['attendance_date'] = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          print("Format dată invalid: $dateValue → folosim azi");
          data['attendance_date'] = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now());
        }
      }

      print("Date finale trimise către backend:");
      print(data);

      final response = await attendanceDataSource.createAttendance(data, token);

      print("Răspuns backend: $response");

      Get.snackbar(
        'Succes',
        'Prezența a fost înregistrată',
        backgroundColor: Colors.green[800],
      );
    } catch (e, stack) {
      print("EROARE la marcarea prezenței:");
      print(e);
      print(stack);

      Get.snackbar(
        'Eroare',
        'Nu s-a putut înregistra: ${e.toString().split('\n').first}',
        backgroundColor: Colors.red[800],
      );
    } finally {
      isLoadingAttendance.value = false;
      print("=== markAttendanceForStudent END ===");
    }
  }

  Future<void> createGradesForStudents(
    List<String> studentIds,
    Map<String, dynamic> baseGradeData,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      for (var studentId in studentIds) {
        final gradeData = Map<String, dynamic>.from(baseGradeData);
        gradeData['student_id'] = studentId;
        gradeData['teacher_id'] = teacher.value?.id;
        await gradeDataSource.createGrade(gradeData, token);
      }

      if (teacher.value != null) {
        await fetchTeacherGrades();
      }
    } catch (e) {
      print("Error creating grades: $e");
      rethrow;
    }
  }

  String? getSubjectIdForClass(String classId) {
    // Find schedule for this class taught by current teacher
    final schedule = teacherSchedules.firstWhereOrNull(
      (s) => s.classId == classId,
    );
    return schedule?.subjectId;
  }

  // Get subject name for a specific class
  String? getSubjectNameForClass(String classId) {
    final schedule = teacherSchedules.firstWhereOrNull(
      (s) => s.classId == classId,
    );
    return schedule?.subjectName;
  }

  // Try to resolve subject id for a class; if not present in teacherSchedules, fetch class schedule from server
  Future<String?> resolveSubjectIdForClass(String classId) async {
    // Guard: invalid classId
    if (classId.isEmpty) return null;

    // First try existing cached schedules
    final existing = getSubjectIdForClass(classId);
    if (existing != null && existing.isNotEmpty) return existing;

    // If not found, try to fetch the class schedule and look for entries taught by current teacher
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return null;

      final classSchedules = await scheduleDataSource.getClassSchedule(
        classId,
        token,
      );
      if (classSchedules.isEmpty) return null;

      // Update local cache with any schedules that are new
      final newSchedules = classSchedules
          .where((s) => !teacherSchedules.any((ts) => ts.id == s.id))
          .toList();
      if (newSchedules.isNotEmpty) {
        teacherSchedules.addAll(newSchedules);
      }

      // Find schedule from this teacher
      final match = classSchedules.firstWhereOrNull(
        (s) => s.teacherId == teacher.value?.id,
      );
      return match?.subjectId;
    } catch (e) {
      print('Error resolving subject for class $classId: $e');
      return null;
    }
  }
}
