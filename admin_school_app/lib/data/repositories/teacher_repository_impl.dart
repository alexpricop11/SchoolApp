import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../data_sources/teacher_data_source.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherDataSource dataSource;

  TeacherRepositoryImpl(this.dataSource);

  @override
  Future<List<TeacherEntity>> getTeachers() async {
    return await dataSource.getTeachers();
  }

  @override
  Future<TeacherEntity?> getTeacher(String teacherId) async {
    return await dataSource.getTeacher(teacherId);
  }

  @override
  Future<TeacherEntity?> createTeacher(TeacherEntity teacher) async {
    final model = TeacherModel(
      id: teacher.id,
      userId: teacher.userId,
      schoolId: teacher.schoolId,
      specialization: teacher.specialization,
    );
    return await dataSource.createTeacher(model);
  }

  @override
  Future<TeacherEntity?> updateTeacher(String teacherId, TeacherEntity teacher) async {
    final model = TeacherModel(
      id: teacher.id,
      userId: teacher.userId,
      schoolId: teacher.schoolId,
      specialization: teacher.specialization,
    );
    return await dataSource.updateTeacher(teacherId, model);
  }

  @override
  Future<bool> deleteTeacher(String teacherId) async {
    return await dataSource.deleteTeacher(teacherId);
  }
}