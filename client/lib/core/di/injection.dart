import 'package:SchoolApp/features/student/domain/repositories/student_repository.dart';
import 'package:SchoolApp/features/student/domain/usecase/student_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/datasource/auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_email_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/school/data/datasource/school_remote_data_source.dart';
import '../../features/school/data/repositories/school_repository_impl.dart';
import '../../features/school/domain/repositories/school_repository.dart';
import '../../features/school/domain/usecases/get_schools_usecase.dart';
import '../../features/school/domain/usecases/create_school_usecase.dart';
import '../../features/school/domain/usecases/update_school_usecase.dart';
import '../../features/school/domain/usecases/delete_school_usecase.dart';
import '../../features/school/presentation/controllers/school_controllers.dart';
import '../../features/student/data/datasource/student_remote_data_source.dart';
import '../../features/student/data/repositories/student_repository_impl.dart';
import '../../features/student/presentation/controllers/student_controller.dart';
import '../../features/teacher/data/datasource/teacher_remote_data_source.dart';
import '../../features/teacher/data/repositories/teacher_repository_impl.dart';
import '../../features/teacher/domain/repositories/teacher_repository.dart';
import '../../features/teacher/domain/usecases/teacher_usecases.dart';
import '../../features/teacher/presentation/controllers/teacher_controller.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasource/password_data_source.dart';
import '../../features/auth/data/repositories/password_repositories_impl.dart';
import '../../features/auth/domain/repositories/password_repositories.dart';
import '../../features/auth/domain/usecases/send_reset_code_usecase.dart';

import '../../features/auth/presentation/controllers/password_controller.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );

  // --- Remote DataSource ---
  // -------------------- STUDENTS --------------------

  // DataSource
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(sl<StudentRemoteDataSource>()),
  );

  // UseCase
  sl.registerLazySingleton(() => StudentUseCase(sl<StudentRepository>()));

  // Controller
  sl.registerFactory(() => StudentController(sl<StudentUseCase>()));

  // -------------------- AUTH --------------------
  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // --- UseCases ---
  sl.registerLazySingleton(() => CheckEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));

  // --- Controller ---
  sl.registerFactory(
    () => LoginController(sl<CheckEmailUseCase>(), sl<LoginUseCase>()),
  );

  // -------------------- SCHOOLS --------------------
  // DataSource
  sl.registerLazySingleton<SchoolRemoteDataSource>(
    () => SchoolRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<SchoolRepository>(
    () => SchoolRepositoryImpl(sl<SchoolRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetSchoolsUseCase(sl<SchoolRepository>()));
  sl.registerLazySingleton(() => CreateSchoolUseCase(sl<SchoolRepository>()));
  sl.registerLazySingleton(() => UpdateSchoolUseCase(sl<SchoolRepository>()));
  sl.registerLazySingleton(() => DeleteSchoolUseCase(sl<SchoolRepository>()));
  // Controller
  sl.registerFactory(() => SchoolController());

  // --- Password (reset / activation) feature ---
  sl.registerLazySingleton<PasswordDataSource>(
    () => PasswordDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PasswordRepository>(
    () => PasswordRepositoryImpl(sl<PasswordDataSource>()),
  );

  sl.registerLazySingleton(
    () => SendResetCodeUseCase(sl<PasswordRepository>()),
  );
  sl.registerLazySingleton(
    () => ResetPasswordUseCase(sl<PasswordRepository>()),
  );
  sl.registerLazySingleton(
    () => SendActivationCodeUseCase(sl<PasswordRepository>()),
  );
  sl.registerLazySingleton(() => SetPasswordUseCase(sl<PasswordRepository>()));

  sl.registerFactory(
    () => PasswordController(
      sendResetCodeUseCase: sl<SendResetCodeUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      sendActivationCodeUseCase: sl<SendActivationCodeUseCase>(),
      setPasswordUseCase: sl<SetPasswordUseCase>(),
    ),
  );
  // --- Teacher Feature ---
  sl.registerLazySingleton<TeacherRemoteDataSource>(
    () => TeacherRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<TeacherRepository>(
    () =>
        TeacherRepositoryImpl(remoteDataSource: sl<TeacherRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(
    () => GetAllTeachersUseCase(sl<TeacherRepository>()),
  );
  sl.registerLazySingleton(
    () => GetTeacherByIdUseCase(sl<TeacherRepository>()),
  );
  sl.registerLazySingleton(() => CreateTeacherUseCase(sl<TeacherRepository>()));
  sl.registerLazySingleton(() => UpdateTeacherUseCase(sl<TeacherRepository>()));
  sl.registerLazySingleton(() => DeleteTeacherUseCase(sl<TeacherRepository>()));

  // Controller
  sl.registerFactory(
    () => TeacherController(
      getAllTeachersUseCase: sl<GetAllTeachersUseCase>(),
      getTeacherByIdUseCase: sl<GetTeacherByIdUseCase>(),
      createTeacherUseCase: sl<CreateTeacherUseCase>(),
      updateTeacherUseCase: sl<UpdateTeacherUseCase>(),
      deleteTeacherUseCase: sl<DeleteTeacherUseCase>(),
    ),
  );
}
