import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:tms_app/data/repositories/course_repository_impl.dart';
import 'package:tms_app/data/services/auth_service.dart'; // Import AuthService
import 'package:tms_app/data/services/course_service.dart';
import 'package:tms_app/data/services/user_service.dart'; // Import UserService
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/forgot_password_usecase.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/presentation/controller/verify_otp_controller.dart'; // Import LoginUseCase
import 'package:tms_app/data/datasources/blog_data.dart'; // Import BlogDataSource

// Khởi tạo GetIt cho Dependency Injection
final sl = GetIt.instance;

void setupLocator() {
  // Đăng ký Dio cho các yêu cầu HTTP
  sl.registerLazySingleton<Dio>(() => Dio());

  // Đăng ký các Service
  sl.registerLazySingleton(() => AuthService(sl())); // Đăng ký AuthService
  sl.registerLazySingleton(() => UserService(sl())); // Đăng ký UserService
  sl.registerLazySingleton(() => CourseService(sl())); // Đăng ký CourseService
  sl.registerLazySingleton(() => BlogDataSource()); // Đăng ký BlogDataSource

  // Đăng ký các Repository
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      authService: sl(),
      userService: sl(),
    ),
  ); // Đăng ký AccountRepository
  sl.registerLazySingleton<CourseRepository>(() =>
      CourseRepositoryImpl(courseService: sl())); // Đăng ký CourseRepository

  // Đăng ký các UseCase
  sl.registerFactory(() => LoginUseCase(sl())); // Đăng ký UseCase cho Login
  sl.registerFactory(() => CourseUseCase(sl())); // Đăng ký UseCase cho Course
  sl.registerFactory(() =>
      RegisterUseCase(accountRepository: sl())); // Đăng ký UseCase cho Register
  sl.registerFactory(
      () => ForgotPasswordUseCase(sl())); // Đăng ký UseCase cho ForgotPassword
  sl.registerLazySingleton(() => VerifyOtpController(
      forgotPasswordController: sl<ForgotPasswordController>()));
}
