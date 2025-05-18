import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/repositories/blog_repository_impl.dart';
import 'package:tms_app/data/repositories/cart_repository_impl.dart';

import 'package:tms_app/data/repositories/course_repository_impl.dart';
import 'package:tms_app/data/repositories/document_repository_impl.dart';
import 'package:tms_app/data/repositories/my_course/my_course_list_repository_impl.dart';
import 'package:tms_app/data/repositories/my_course/course_lesson_repository_impl.dart'; // Import course lesson repository
import 'package:tms_app/data/services/auth_service.dart'; // Import AuthService
import 'package:tms_app/data/services/blog_service.dart';
import 'package:tms_app/data/services/cart/cart_service.dart';
import 'package:tms_app/data/services/course/course_service.dart';
import 'package:tms_app/data/services/document/document_service.dart';
import 'package:tms_app/data/services/my_course/my_course_list_service.dart';
import 'package:tms_app/data/services/my_course/course_lesson_service.dart'; // Import course lesson service
import 'package:tms_app/data/services/user_service.dart'; // Import UserService
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';
import 'package:tms_app/domain/repositories/cart_repository.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';
import 'package:tms_app/domain/repositories/my_course/my_course_list_repository.dart';
import 'package:tms_app/domain/repositories/my_course/course_lesson_repository.dart'; // Import course lesson repository interface
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/domain/usecases/forgot_password_usecase.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/my_course_list_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart'; // Import course lesson usecase
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/domain/usecases/update_account_usecase.dart';
import 'package:tms_app/domain/usecases/overview_my_account_usecase.dart';
import 'package:tms_app/presentation/controller/login/forgot_password_controller.dart';
import 'package:tms_app/presentation/controller/my_account/setting/update_account_controller.dart';
import 'package:tms_app/presentation/controller/login/verify_otp_controller.dart'; // Import LoginUseCase// Import BlogDataSource
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
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/core/interceptors/token_interceptor.dart';
import 'package:tms_app/core/network/dio_client.dart';
import 'package:tms_app/core/auth/auth_manager.dart';

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
  // Đăng ký AuthManager first to avoid circular dependencies
  sl.registerLazySingleton(() => AuthManager());

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

  // Đăng ký DioClient trước khi thiết lập TokenInterceptor
  _registerDioClient();

  // Thiết lập TokenInterceptor sau khi các service đã được đăng ký
  _setupTokenInterceptor();
}

// Hàm mới để thiết lập interceptor cho Dio
void _setupTokenInterceptor() {
  // Lấy instance của Dio và AuthService đã đăng ký
  final dio = sl<Dio>();
  final authService = sl<AuthService>();

  // Tạo và đăng ký TokenInterceptor
  final tokenInterceptor = TokenInterceptor(dio: dio, authService: authService);

  // Thêm interceptor vào Dio
  dio.interceptors.add(tokenInterceptor);

  print('Đã thiết lập TokenInterceptor');
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
  sl.registerLazySingleton(() => CartService(sl()));
  // Đăng ký MyCourseListService
  sl.registerLazySingleton(() => MyCourseListService(sl()));
  // Đăng ký CourseLessonService
  sl.registerLazySingleton(() => CourseLessonService(sl()));
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

  sl.registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(cartService: sl<CartService>()));

  // Đăng ký MyCourseListRepository
  sl.registerLazySingleton<MyCourseListRepository>(
      () => MyCourseListRepositoryImpl(sl<MyCourseListService>()));

  // Đăng ký CourseLessonRepository
  sl.registerLazySingleton<CourseLessonRepository>(
      () => CourseLessonRepositoryImpl(sl<CourseLessonService>()));
}

// Đăng ký tất cả các UseCase
void _registerUseCases() {
  // Login & Registration
  sl.registerLazySingleton(() => LoginUseCase(sl<AccountRepository>()));
  sl.registerLazySingleton(
      () => RegisterUseCase(accountRepository: sl<AccountRepository>()));
  sl.registerLazySingleton(
      () => ForgotPasswordUseCase(sl<AccountRepository>()));
  sl.registerLazySingleton(
      () => ChangePasswordUseCase(sl<AccountRepository>()));
  sl.registerLazySingleton(() => UpdateAccountUseCase(sl<AccountRepository>()));
  sl.registerLazySingleton(
      () => OverviewMyAccountUseCase(sl<AccountRepository>()));

  // Courses & Content
  sl.registerLazySingleton(() => CourseUseCase(sl<CourseRepository>()));
  sl.registerLazySingleton(() => BannerUseCase(sl<BannerRepository>()));
  sl.registerLazySingleton(() => CategoryUseCase(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => BlogUsecase(sl<BlogRepository>()));
  sl.registerLazySingleton(
      () => PracticeTestUseCase(sl<PracticeTestRepository>()));
  sl.registerLazySingleton(() => DocumentUseCase(sl<DocumentRepository>()));
  sl.registerLazySingleton(() => CartUseCase(sl<CartRepository>()));

  // My Courses
  sl.registerLazySingleton(
      () => MyCourseListUseCase(sl<MyCourseListRepository>()));
  // Course Lessons
  sl.registerLazySingleton(
      () => CourseLessonUseCase(sl<CourseLessonRepository>()));
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

  // Đảm bảo CourseController chỉ được đăng ký một lần
  if (!sl.isRegistered<CourseController>()) {
    sl.registerLazySingleton<CourseController>(() => CourseController(
          sl<CourseUseCase>(),
          categoryUseCase: sl<CategoryUseCase>(),
        ));
  }
}

// Thêm hàm để đăng ký DioClient
void _registerDioClient() {
  // Đảm bảo Dio và AuthService đã được đăng ký
  final dio = sl<Dio>();
  final authService = sl<AuthService>();

  // Đăng ký DioClient
  sl.registerLazySingleton<DioClient>(() => DioClient(dio, authService));

  print('Đã đăng ký DioClient');
}
