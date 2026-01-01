import 'package:get/get.dart';
import '../../../domain/entities/teacher_entity.dart';
import '../../../domain/usecases/teacher/get_teachers_usecase.dart';
import '../../../domain/usecases/teacher/delete_teacher_usecase.dart';
import 'package:get_it/get_it.dart';

class TeachersController extends GetxController {
  final GetTeachersUseCase getTeachersUseCase = GetIt.instance.get<GetTeachersUseCase>();
  final DeleteTeacherUseCase deleteTeacherUseCase = GetIt.instance.get<DeleteTeacherUseCase>();

  var teachers = <TeacherEntity>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await getTeachersUseCase();
      teachers.value = result;
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea profesorilor: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTeacher(String teacherId) async {
    try {
      final success = await deleteTeacherUseCase(teacherId);
      if (success) {
        teachers.removeWhere((teacher) => teacher.id == teacherId);
        Get.snackbar('Succes', 'Profesorul a fost șters');
      } else {
        Get.snackbar('Eroare', 'Nu s-a putut șterge profesorul');
      }
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea profesorului: $e');
    }
  }
}