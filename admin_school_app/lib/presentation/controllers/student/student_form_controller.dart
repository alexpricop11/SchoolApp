import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/usecases/student/create_student_usecase.dart';
import '../../../domain/usecases/student/update_student_usecase.dart';
import '../../../domain/usecases/student/get_student_usecase.dart';
import 'package:get_it/get_it.dart';

class StudentFormController extends GetxController {
  final CreateStudentUseCase createStudentUseCase = GetIt.instance.get<CreateStudentUseCase>();
  final UpdateStudentUseCase updateStudentUseCase = GetIt.instance.get<UpdateStudentUseCase>();
  final GetStudentUseCase getStudentUseCase = GetIt.instance.get<GetStudentUseCase>();

  final userIdController = TextEditingController();
  final classIdController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isEditMode = false.obs;
  String? studentId;

  StudentFormController({this.studentId});

  @override
  void onInit() {
    super.onInit();
    if (studentId != null) {
      isEditMode.value = true;
      loadStudent();
    }
  }

  Future<void> loadStudent() async {
    if (studentId == null) return;

    isLoading.value = true;
    try {
      final student = await getStudentUseCase(studentId!);
      if (student != null) {
        userIdController.text = student.userId.toString();
        classIdController.text = student.classId.toString();
      }
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea elevului: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveStudent() async {
    if (userIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul utilizatorului';
      return;
    }
    if (classIdController.text.trim().isEmpty) {
      errorMessage.value = 'Introduceți ID-ul clasei';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final student = StudentEntity(
      id: studentId,
      userId: userIdController.text.trim(),
      classId: classIdController.text.trim(),
    );

    try {
      StudentEntity? result;
      if (isEditMode.value && studentId != null) {
        result = await updateStudentUseCase(studentId!, student);
      } else {
        result = await createStudentUseCase(student);
      }

      if (result != null) {
        Get.back(result: true);
        Get.snackbar(
          'Succes',
          isEditMode.value ? 'Elevul a fost actualizat' : 'Elevul a fost creat',
        );
      } else {
        errorMessage.value = 'Eroare la salvarea elevului';
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
    classIdController.dispose();
    super.onClose();
  }
}