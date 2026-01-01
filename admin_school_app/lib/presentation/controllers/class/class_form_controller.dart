import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/class_entity.dart';
import '../../../domain/usecases/class/create_class_usecase.dart';
import '../../../domain/usecases/class/update_class_usecase.dart';
import '../../../domain/usecases/class/get_class_usecase.dart';
import 'package:get_it/get_it.dart';

class ClassFormController extends GetxController {
  final CreateClassUseCase createClassUseCase = GetIt.instance.get<CreateClassUseCase>();
  final UpdateClassUseCase updateClassUseCase = GetIt.instance.get<UpdateClassUseCase>();
  final GetClassUseCase getClassUseCase = GetIt.instance.get<GetClassUseCase>();

  final nameController = TextEditingController();
  final gradeIdController = TextEditingController();
  final teacherIdController = TextEditingController();
  final schoolIdController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isEditMode = false.obs;
  String? classId;

  ClassFormController({this.classId});

  @override
  void onInit() {
    super.onInit();
    if (classId != null) {
      isEditMode.value = true;
      loadClass();
    }
  }

  Future<void> loadClass() async {
    if (classId == null) return;

    isLoading.value = true;
    try {
      final classEntity = await getClassUseCase(classId!);
      if (classEntity != null) {
        nameController.text = classEntity.name;
        gradeIdController.text = classEntity.gradeId.toString();
        teacherIdController.text = classEntity.teacherId?.toString() ?? '';
        schoolIdController.text = classEntity.schoolId.toString();
      }
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea clasei: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveClass() async {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți numele clasei';
      return;
    }
    if (gradeIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul gradului';
      return;
    }
    if (schoolIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul școlii';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final classEntity = ClassEntity(
      id: classId,
      name: nameController.text.trim(),
      gradeId: gradeIdController.text.trim(),
      teacherId: teacherIdController.text.trim(),
      schoolId: schoolIdController.text.trim(),
    );

    try {
      ClassEntity? result;
      if (isEditMode.value && classId != null) {
        result = await updateClassUseCase(classId!, classEntity);
      } else {
        result = await createClassUseCase(classEntity);
      }

      if (result != null) {
        Get.back(result: true);
        Get.snackbar(
          'Succes',
          isEditMode.value ? 'Clasa a fost actualizată' : 'Clasa a fost creată',
        );
      } else {
        errorMessage.value = 'Eroare la salvarea clasei';
      }
    } catch (e) {
      errorMessage.value = 'Eroare: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    gradeIdController.dispose();
    teacherIdController.dispose();
    schoolIdController.dispose();
    super.onClose();
  }
}