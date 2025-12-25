import 'package:get/get.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/usecases/teacher_usecases.dart';

class TeacherController extends GetxController {
  final GetAllTeachersUseCase getAllTeachersUseCase;
  final GetTeacherByIdUseCase getTeacherByIdUseCase;
  final CreateTeacherUseCase createTeacherUseCase;
  final UpdateTeacherUseCase updateTeacherUseCase;
  final DeleteTeacherUseCase deleteTeacherUseCase;

  TeacherController({
    required this.getAllTeachersUseCase,
    required this.getTeacherByIdUseCase,
    required this.createTeacherUseCase,
    required this.updateTeacherUseCase,
    required this.deleteTeacherUseCase,
  });

  var teachers = <Teacher>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // attempt to load teachers when controller is initialized
    fetchAllTeachers();
  }

  Future<void> fetchAllTeachers() async {
    try {
      isLoading.value = true;
      teachers.value = await getAllTeachersUseCase();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    final newTeacher = await createTeacherUseCase(teacher);
    teachers.add(newTeacher);
  }

  Future<void> updateTeacher(String id, Teacher teacher) async {
    final updated = await updateTeacherUseCase(id, teacher);
    final index = teachers.indexWhere((t) => t.id == id);
    if (index != -1) {
      teachers[index] = updated;
    }
  }

  Future<void> deleteTeacher(String id) async {
    await deleteTeacherUseCase(id);
    teachers.removeWhere((t) => t.id == id);
  }
}
