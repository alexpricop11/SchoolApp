import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/teacher_entity.dart';
import '../../../domain/usecases/teacher/create_teacher_usecase.dart';
import '../../../domain/usecases/teacher/update_teacher_usecase.dart';
import '../../../domain/usecases/teacher/get_teacher_usecase.dart';
import 'package:get_it/get_it.dart';

class TeacherFormController extends GetxController {
  final CreateTeacherUseCase createTeacherUseCase = GetIt.instance
      .get<CreateTeacherUseCase>();
  final UpdateTeacherUseCase updateTeacherUseCase = GetIt.instance
      .get<UpdateTeacherUseCase>();
  final GetTeacherUseCase getTeacherUseCase = GetIt.instance
      .get<GetTeacherUseCase>();

  final userIdController = TextEditingController();
  final schoolIdController = TextEditingController();
  final specializationController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isEditMode = false.obs;
  String? teacherId;

  TeacherFormController({this.teacherId});

  @override
  void onInit() {
    super.onInit();
    if (teacherId != null) {
      isEditMode.value = true;
      loadTeacher();
    }
  }

  Future<void> loadTeacher() async {
    if (teacherId == null) return;

    isLoading.value = true;
    try {
      final teacher = await getTeacherUseCase(teacherId!);
      if (teacher != null) {
        userIdController.text = teacher.userId.toString();
        schoolIdController.text = teacher.schoolId.toString();
        specializationController.text = teacher.specialization ?? '';
      }
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea profesorului: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTeacher() async {
    if (userIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul utilizatorului';
      return;
    }
    if (schoolIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul școlii';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final teacher = TeacherEntity(
      id: teacherId,
      userId: userIdController.text.trim(),
      schoolId: schoolIdController.text.trim(),
      specialization: specializationController.text.trim(),
    );

    try {
      TeacherEntity? result;
      if (isEditMode.value && teacherId != null) {
        result = await updateTeacherUseCase(teacherId!, teacher);
      } else {
        result = await createTeacherUseCase(teacher);
      }

      if (result != null) {
        Get.back(result: true);
        Get.snackbar(
          'Succes',
          isEditMode.value
              ? 'Profesorul a fost actualizat'
              : 'Profesorul a fost creat',
        );
      } else {
        errorMessage.value = 'Eroare la salvarea profesorului';
      }
    } catch (e) {
      errorMessage.value = 'Eroare: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    userIdController.dispose();
    schoolIdController.dispose();
    specializationController.dispose();
    super.onClose();
  }
}
