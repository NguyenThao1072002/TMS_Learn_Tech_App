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
import 'package:tms_app/data/services/banner_service.dart'; // Import BannerService
import 'package:tms_app/data/repositories/banner_repository_impl.dart'; // Import BannerRepositoryImpl
import 'package:tms_app/domain/repositories/banner_repository.dart'; // Import BannerRepository
import 'package:tms_app/domain/usecases/banner_usecase.dart'; // Import BannerUseCase
import 'package:tms_app/data/services/category_service.dart'; // Import CategoryService
import 'package:tms_app/data/repositories/category_repository_impl.dart'; // Import CategoryRepositoryImpl
import 'package:tms_app/domain/repositories/category_repository.dart'; // Import CategoryRepository
import 'package:tms_app/domain/usecases/category_usecase.dart'; // Import CategoryUseCase
import 'package:tms_app/core/network/vietnamese_encoding_interceptor.dart';

// Đảm bảo các import không bị xóa bởi công cụ IDE
// ignore: unused_element
void _keepImports() {
  // Tạo biến dummy để giữ các import, không gọi thực tế
  CategoryService? a;
  CategoryRepositoryImpl? b;
  CategoryRepository? c;
  CategoryUseCase? d;
  a;
  b;
  c;
  d;
}

// Khởi tạo GetIt cho Dependency Injection
final sl = GetIt.instance;

void setupLocator() {
  // Đăng ký Dio cho các yêu cầu HTTP
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // Thêm interceptor xử lý encoding tiếng Việt
  //  dio.interceptors.add(VietnameseEncodingInterceptor());
    return dio;
  });

  // Đăng ký các Service trước
  _registerServices();

  // Đăng ký các Repository
  _registerRepositories();

  // Đăng ký các UseCase
  _registerUseCases();

  // Đăng ký các Controller
  sl.registerLazySingleton(() => VerifyOtpController(
      forgotPasswordController: sl<ForgotPasswordController>()));
}

// Đăng ký tất cả các Service
void _registerServices() {
  sl.registerLazySingleton(() => AuthService(sl())); // Đăng ký AuthService
  sl.registerLazySingleton(() => UserService(sl())); // Đăng ký UserService
  sl.registerLazySingleton(() => CourseService(sl())); // Đăng ký CourseService
  sl.registerLazySingleton(() => BlogDataSource()); // Đăng ký BlogDataSource
  sl.registerLazySingleton(() => BannerService()); // Đăng ký BannerService
  sl.registerLazySingleton(() => CategoryService()); // Đăng ký CategoryService
}

// Đăng ký tất cả các Repository
void _registerRepositories() {
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      authService: sl(),
      userService: sl(),
    ),
  ); // Đăng ký AccountRepository
  sl.registerLazySingleton<CourseRepository>(() =>
      CourseRepositoryImpl(courseService: sl())); // Đăng ký CourseRepository
  sl.registerLazySingleton<BannerRepository>(() =>
      BannerRepositoryImpl(bannerService: sl())); // Đăng ký BannerRepository
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(
      categoryService: sl())); // Đăng ký CategoryRepository
}

// Đăng ký tất cả các UseCase
void _registerUseCases() {
  // Đăng ký UseCase cho Login
  sl.registerFactory(() => LoginUseCase(sl()));

  // Đăng ký UseCase cho Course
  sl.registerFactory(() => CourseUseCase(sl()));

  // Đăng ký UseCase cho Register
  sl.registerFactory(() => RegisterUseCase(accountRepository: sl()));

  // Đăng ký UseCase cho ForgotPassword
  sl.registerFactory(() => ForgotPasswordUseCase(sl()));

  // Đăng ký UseCase cho Banner
  sl.registerFactory(() => BannerUseCase(sl()));

  // Đăng ký UseCase cho Category - dùng registerLazySingleton
  sl.registerLazySingleton(() {
    final repo = sl<CategoryRepository>();
    return CategoryUseCase(repo);
  });
}
