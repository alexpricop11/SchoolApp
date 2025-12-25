import '../../domain/entities/teacher.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasource/teacher_remote_data_source.dart';
import '../model/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Teacher>> getAllTeachers() => remoteDataSource.getAllTeachers();

  @override
  Future<Teacher> getTeacherById(String id) =>
      remoteDataSource.getTeacherById(id);

  @override
  Future<Teacher> createTeacher(Teacher teacher) =>
      remoteDataSource.createTeacher(teacher as TeacherModel);

  @override
  Future<Teacher> updateTeacher(String id, Teacher teacher) =>
      remoteDataSource.updateTeacher(id, teacher as TeacherModel);

  @override
  Future<void> deleteTeacher(String id) => remoteDataSource.deleteTeacher(id);
}
