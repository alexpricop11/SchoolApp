import 'package:get/get.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/usecases/student/get_students_usecase.dart';
import '../../../domain/usecases/student/delete_student_usecase.dart';
import 'package:get_it/get_it.dart';

class StudentsController extends GetxController {
  final GetStudentsUseCase getStudentsUseCase = GetIt.instance.get<GetStudentsUseCase>();
  final DeleteStudentUseCase deleteStudentUseCase = GetIt.instance.get<DeleteStudentUseCase>();

  var students = <StudentEntity>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await getStudentsUseCase();
      students.value = result;
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea elevilor: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      final success = await deleteStudentUseCase(studentId);
      if (success) {
        students.removeWhere((student) => student.id == studentId);
        Get.snackbar('Succes', 'Elevul a fost șters');
      } else {
        Get.snackbar('Eroare', 'Nu s-a putut șterge elevul');
      }
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea elevului: $e');
    }
  }
}