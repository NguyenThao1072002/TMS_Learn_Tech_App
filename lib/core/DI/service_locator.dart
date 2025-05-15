import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/repositories/blog_repository_impl.dart';

import 'package:tms_app/data/repositories/course_repository_impl.dart';
import 'package:tms_app/data/repositories/document_repository_impl.dart';
import 'package:tms_app/data/services/auth_service.dart'; // Import AuthService
import 'package:tms_app/data/services/blog_service.dart';
import 'package:tms_app/data/services/course/course_service.dart';
import 'package:tms_app/data/services/document/document_service.dart';
import 'package:tms_app/data/services/user_service.dart'; // Import UserService
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/domain/usecases/forgot_password_usecase.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/domain/usecases/update_account_usecase.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/presentation/controller/my_account/setting/update_account_controller.dart';
import 'package:tms_app/presentation/controller/verify_otp_controller.dart'; // Import LoginUseCase// Import BlogDataSource
import 'package:tms_app/data/services/banner_service.dart'; // Import BannerService
import 'package:tms_app/data/repositories/banner_repository_impl.dart'; // Import BannerRepositoryImpl
import 'package:tms_app/domain/repositories/banner_repository.dart'; // Import BannerRepository
import 'package:tms_app/domain/usecases/banner_usecase.dart'; // Import BannerUseCase
import 'package:tms_app/data/services/category_service.dart'; // Import CategoryService
import 'package:tms_app/data/repositories/category_repository_impl.dart'; // Import CategoryRepositoryImpl
import 'package:tms_app/domain/repositories/category_repository.dart'; // Import CategoryRepository
import 'package:tms_app/domain/usecases/category_usecase.dart'; // Import CategoryUseCase
// Practice Test imports
import 'package:tms_app/data/services/practice_test/practice_test_service.dart';
import 'package:tms_app/data/repositories/practice_test_repository_impl.dart';
import 'package:tms_app/domain/repositories/practice_test_repository.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/domain/usecases/change_password_usecase.dart';

// Đảm bảo các import không bị xóa bởi công cụ IDE
// ignore: unused_element
void _keepImports() {
  // Tạo biến dummy để giữ các import, không gọi thực tế
  CategoryService? a;
  CategoryRepositoryImpl? b;
  CategoryRepository? c;
  CategoryUseCase? d;
  PracticeTestService? e;
  PracticeTestRepositoryImpl? f;
  PracticeTestRepository? g;
  PracticeTestUseCase? h;
  a;
  b;
  c;
  d;
  e;
  f;
  g;
  h;
}

// Khởi tạo GetIt cho Dependency Injection
final sl = GetIt.instance;

void setupLocator() {
  // Đăng ký Dio cho các yêu cầu HTTP
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (log) {
          print('🌐 DIO: $log');
        },
      ),
    );

    return dio;
  });

  // Đăng ký các Service trước
  _registerServices();

  // Đăng ký các Repository
  _registerRepositories();

  // Đăng ký các UseCase
  _registerUseCases();

  // Đăng ký các Controller
  _registerControllers();
}

// Đăng ký tất cả các Service
void _registerServices() {
  sl.registerLazySingleton(() => AuthService(sl()));
  sl.registerLazySingleton(() => UserService(sl()));

  // Sử dụng lớp CourseService gốc
  sl.registerLazySingleton(() => CourseService(sl()));
  sl.registerLazySingleton(() => BlogService(sl()));
  sl.registerLazySingleton(() => BannerService());
  sl.registerLazySingleton(() => CategoryService());
  sl.registerLazySingleton(() => PracticeTestService(sl()));
  sl.registerLazySingleton(() => DocumentService(sl()));
}

// Đăng ký tất cả các Repository
void _registerRepositories() {
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      authService: sl(),
      userService: sl(),
    ),
  ); // Đăng ký AccountRepository

  sl.registerLazySingleton<CourseRepository>(
      () => CourseRepositoryImpl(courseService: sl<CourseService>()));

  sl.registerLazySingleton<BannerRepository>(
      () => BannerRepositoryImpl(bannerService: sl()));

  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(categoryService: sl()));

  sl.registerLazySingleton<BlogRepository>(() => BlogRepositoryImpl(
        blogService: sl(),
      ));

  sl.registerLazySingleton<PracticeTestRepository>(() =>
      PracticeTestRepositoryImpl(
          practiceTestService: sl<PracticeTestService>()));

  sl.registerLazySingleton<DocumentRepository>(
      () => DocumentRepositoryImpl(documentService: sl<DocumentService>()));
}

// Đăng ký tất cả các UseCase
void _registerUseCases() {
  sl.registerFactory(() => LoginUseCase(sl()));

  sl.registerFactory(() => CourseUseCase(sl()));

  sl.registerFactory(() => RegisterUseCase(accountRepository: sl()));

  sl.registerFactory(() => ForgotPasswordUseCase(sl()));

  sl.registerFactory(() => BannerUseCase(sl()));

  sl.registerLazySingleton(() => BlogUsecase(sl()));

  sl.registerLazySingleton(() => DocumentUseCase(sl()));

  sl.registerLazySingleton(() {
    final repo = sl<CategoryRepository>();
    return CategoryUseCase(repo);
  });

  sl.registerFactory(() => PracticeTestUseCase(sl()));

  // Đăng ký UpdateAccountUseCase - chuyển từ registerFactory sang registerLazySingleton
  sl.registerLazySingleton(() => UpdateAccountUseCase(sl<AccountRepository>()));

  sl.registerLazySingleton(
      () => ChangePasswordUseCase(sl<AccountRepository>()));
}

// Thêm một phương thức mới riêng để đăng ký controllers
void _registerControllers() {
  sl.registerLazySingleton<VerifyOtpController>(
    () => VerifyOtpController(
      forgotPasswordController: sl<ForgotPasswordController>(),
    ),
  );

  // Đảm bảo đăng ký với kiểu cụ thể
  sl.registerLazySingleton<UnifiedSearchController>(
    () => UnifiedSearchController(),
  );

  // Đảm bảo ForgotPasswordController được đăng ký trước khi đăng ký các controller khác phụ thuộc vào nó
  if (!sl.isRegistered<ForgotPasswordController>()) {
    sl.registerLazySingleton<ForgotPasswordController>(
      () =>
          ForgotPasswordController(accountRepository: sl<AccountRepository>()),
    );
  }

  // Đăng ký UpdateAccountController - đảm bảo UpdateAccountUseCase đã được đăng ký
  sl.registerLazySingleton<UpdateAccountController>(
    () => UpdateAccountController(
      updateAccountUseCase: sl<UpdateAccountUseCase>(),
    ),
  );
}
