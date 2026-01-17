import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/secure_storage_service.dart';
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
  final GetCurrentTeacherUseCase getCurrentTeacherUseCase = GetIt.instance.get<GetCurrentTeacherUseCase>();
  final GradeRemoteDataSource gradeDataSource = GetIt.instance.get<GradeRemoteDataSource>();
  final HomeworkRemoteDataSource homeworkDataSource = GetIt.instance.get<HomeworkRemoteDataSource>();
  final AttendanceRemoteDataSource attendanceDataSource = GetIt.instance.get<AttendanceRemoteDataSource>();
  final ScheduleRemoteDataSource scheduleDataSource = GetIt.instance.get<ScheduleRemoteDataSource>();
  final MaterialRemoteDataSource materialDataSource = GetIt.instance.get<MaterialRemoteDataSource>();

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
        await fetchTeacherGrades();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching teacher: $e';
      print('Error fetching teacher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GRADES ====================
  Future<void> fetchTeacherGrades() async {
    if (teacher.value == null) return;

    isLoadingGrades.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedGrades = await gradeDataSource.getTeacherGrades(teacher.value!.id, token);
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

      final fetchedGrades = await gradeDataSource.getStudentGrades(studentId, token);
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

      await gradeDataSource.createGrade(gradeData, token);
      await fetchTeacherGrades();
      Get.snackbar('Succes', 'Nota a fost adăugată cu succes!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la adăugarea notei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateGrade(String gradeId, Map<String, dynamic> gradeData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await gradeDataSource.updateGrade(gradeId, gradeData, token);
      await fetchTeacherGrades();
      Get.snackbar('Succes', 'Nota a fost actualizată!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la actualizarea notei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteGrade(String gradeId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await gradeDataSource.deleteGrade(gradeId, token);
      await fetchTeacherGrades();
      Get.snackbar('Succes', 'Nota a fost ștearsă!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea notei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== HOMEWORK ====================
  Future<void> fetchClassHomework(String classId) async {
    isLoadingHomework.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedHomework = await homeworkDataSource.getClassHomework(classId, token);
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

      await homeworkDataSource.createHomework(homeworkData, token);
      Get.snackbar('Succes', 'Tema a fost creată cu succes!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la crearea temei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateHomework(String homeworkId, Map<String, dynamic> homeworkData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await homeworkDataSource.updateHomework(homeworkId, homeworkData, token);
      Get.snackbar('Succes', 'Tema a fost actualizată!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la actualizarea temei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteHomework(String homeworkId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await homeworkDataSource.deleteHomework(homeworkId, token);
      Get.snackbar('Succes', 'Tema a fost ștearsă!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea temei: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== ATTENDANCE ====================
  Future<void> fetchStudentAttendance(String studentId) async {
    isLoadingAttendance.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedAttendance = await attendanceDataSource.getStudentAttendance(studentId, token);
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

      await attendanceDataSource.createAttendance(attendanceData, token);
      Get.snackbar('Succes', 'Prezența a fost înregistrată!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la înregistrarea prezenței: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateAttendance(String attendanceId, Map<String, dynamic> attendanceData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await attendanceDataSource.updateAttendance(attendanceId, attendanceData, token);
      Get.snackbar('Succes', 'Prezența a fost actualizată!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la actualizarea prezenței: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== SCHEDULE ====================
  Future<void> fetchClassSchedule(String classId) async {
    isLoadingSchedule.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedSchedules = await scheduleDataSource.getClassSchedule(classId, token);
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
      Get.snackbar('Succes', 'Orarul a fost creat!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la crearea orarului: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== MATERIALS ====================
  Future<void> fetchTeacherMaterials() async {
    if (teacher.value == null) return;

    isLoadingMaterials.value = true;
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      final fetchedMaterials = await materialDataSource.getTeacherMaterials(teacher.value!.id, token);
      materials.value = fetchedMaterials;
    } catch (e) {
      print('Error fetching materials: $e');
    } finally {
      isLoadingMaterials.value = false;
    }
  }

  Future<void> createMaterial(Map<String, dynamic> materialData) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await materialDataSource.createMaterial(materialData, token);
      await fetchTeacherMaterials();
      Get.snackbar('Succes', 'Materialul a fost încărcat!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la încărcarea materialului: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      await materialDataSource.deleteMaterial(materialId, token);
      await fetchTeacherMaterials();
      Get.snackbar('Succes', 'Materialul a fost șters!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea materialului: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== STATISTICS ====================
  int get totalClasses => classes.length;
  int get totalStudents => allStudents.length;
  int get totalGrades => grades.length;

  // Get grades added this week
  int get gradesThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return grades.where((grade) => grade.createdAt.isAfter(weekAgo)).length;
  }

  // Get absences today
  int get absencesToday {
    final today = DateTime.now();
    return attendanceList.where((att) =>
      att.attendanceDate.year == today.year &&
      att.attendanceDate.month == today.month &&
      att.attendanceDate.day == today.day &&
      att.status == AttendanceStatus.absent
    ).length;
  }
}
