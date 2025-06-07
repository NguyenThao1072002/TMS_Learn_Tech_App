import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/repositories/blog_repository_impl.dart';
import 'package:tms_app/data/repositories/cart_repository_impl.dart';
import 'package:tms_app/data/repositories/course_repository_impl.dart';
import 'package:tms_app/data/repositories/discount_repository_impl.dart';
import 'package:tms_app/data/repositories/document_repository_impl.dart';
import 'package:tms_app/data/repositories/my_course/my_course_list_repository_impl.dart';
import 'package:tms_app/data/repositories/my_course/course_lesson_repository_impl.dart'; 
import 'package:tms_app/data/repositories/my_course/course_progress_repository_impl.dart'; 
import 'package:tms_app/data/repositories/my_course/content_test_repository_impl.dart'; 
import 'package:tms_app/data/repositories/my_course/comment_lession_repository_impl.dart'; 
import 'package:tms_app/data/repositories/my_course/test_submission_repository_impl.dart'; 
import 'package:tms_app/data/repositories/payment_repository_impl.dart';
import 'package:tms_app/data/repositories/teaching_staff_repository_impl.dart'; 
import 'package:tms_app/data/services/auth_service.dart'; 
import 'package:tms_app/data/services/blog_service.dart';
import 'package:tms_app/data/services/cart/cart_service.dart';
import 'package:tms_app/data/services/course/course_service.dart';
import 'package:tms_app/data/services/discount_service.dart';
import 'package:tms_app/data/services/document/document_service.dart';
import 'package:tms_app/data/services/my_course/my_course_list_service.dart';
import 'package:tms_app/data/services/my_course/course_lesson_service.dart'; 
import 'package:tms_app/data/services/my_course/course_progress_service.dart'; 
import 'package:tms_app/data/services/my_course/content_test_service.dart'; 
import 'package:tms_app/data/services/my_course/comment_lession_service.dart'; 
import 'package:tms_app/data/services/payment_service.dart';
import 'package:tms_app/data/services/teaching_staff/teaching_staff_service.dart';
import 'package:tms_app/data/services/user_service.dart'; 
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';
import 'package:tms_app/domain/repositories/cart_repository.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/domain/repositories/discount_repository.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';
import 'package:tms_app/domain/repositories/my_course/my_course_list_repository.dart';
import 'package:tms_app/domain/repositories/my_course/course_lesson_repository.dart'; 
import 'package:tms_app/domain/repositories/my_course/course_progress_repository.dart'; 
import 'package:tms_app/domain/repositories/my_course/content_test_repository.dart'; 
import 'package:tms_app/domain/repositories/my_course/comment_lession_repository.dart'; 
import 'package:tms_app/domain/repositories/my_course/test_submission_repository.dart'; 
import 'package:tms_app/domain/repositories/payment_repository.dart';
import 'package:tms_app/domain/repositories/teaching_staff_repository.dart'; 
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/discount_usecase.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/domain/usecases/forgot_password_usecase.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/my_course_list_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/course_progress_usecase.dart'; 
import 'package:tms_app/domain/usecases/my_course/content_test_usecase.dart'; 
import 'package:tms_app/domain/usecases/my_course/comment_lession_usecase.dart'; 
import 'package:tms_app/domain/usecases/my_course/test_submission_usecase.dart'; 
import 'package:tms_app/domain/usecases/payment_usecase.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/domain/usecases/update_account_usecase.dart';
import 'package:tms_app/domain/usecases/overview_my_account_usecase.dart';
import 'package:tms_app/presentation/controller/discount_controller.dart';
import 'package:tms_app/presentation/controller/login/forgot_password_controller.dart';
import 'package:tms_app/presentation/controller/my_account/setting/update_account_controller.dart';
import 'package:tms_app/presentation/controller/login/verify_otp_controller.dart'; 
import 'package:tms_app/data/services/banner_service.dart'; 
import 'package:tms_app/data/repositories/banner_repository_impl.dart'; 
import 'package:tms_app/domain/repositories/banner_repository.dart'; 
import 'package:tms_app/domain/usecases/banner_usecase.dart'; 
import 'package:tms_app/data/services/category_service.dart'; 
import 'package:tms_app/data/repositories/category_repository_impl.dart'; 
import 'package:tms_app/domain/repositories/category_repository.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart'; 
import 'package:tms_app/data/services/practice_test/practice_test_service.dart';
import 'package:tms_app/data/repositories/practice_test_repository_impl.dart';
import 'package:tms_app/domain/repositories/practice_test_repository.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/controller/payment_controller.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/domain/usecases/change_password_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/core/interceptors/token_interceptor.dart';
import 'package:tms_app/core/network/dio_client.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import 'package:tms_app/presentation/controller/my_course/my_course_controller.dart';
import 'package:tms_app/data/repositories/day_streak_repository_impl.dart';
import 'package:tms_app/domain/repositories/day_streak_repository.dart';
import 'package:tms_app/data/services/day_streak_service.dart';
import 'package:tms_app/domain/usecases/day_streak_usecase.dart';
import 'package:tms_app/presentation/controller/day_streak_controller.dart';
import 'package:tms_app/domain/usecases/teaching_staff/teaching_staff_usecase.dart'; 
import 'package:tms_app/presentation/controller/teaching_staff_controller.dart';
import 'package:tms_app/presentation/controller/my_course/course_progress_controller.dart'; 
import 'package:tms_app/presentation/controller/my_course/test_submission_controller.dart'; 
import 'package:tms_app/data/models/my_course/like_comment_model.dart'; 
import 'package:tms_app/data/repositories/my_course/recent_lesson_reporitory_impl.dart';
import 'package:tms_app/data/services/my_course/recent_lesson_services.dart';
import 'package:tms_app/domain/repositories/my_course/recent_lesson_reporitory.dart';
import 'package:tms_app/domain/usecases/my_course/recent_lesson_usecase.dart';

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
  ContentTestService? i;
  ContentTestRepositoryImpl? j;
  ContentTestRepository? k;
  ContentTestUseCase? l;
  CommentLessonService? m; 
  CommentLessonRepositoryImpl? n; 
  CommentLessonRepository? o; 
  CommentLessonUseCase? p; 
  LikeCommentResponse? q; 
  LikeCommentRequest? r;
  RecentLessonService? s;
  RecentLessonRepositoryImpl? t;
  RecentLessonRepository? u;
  RecentLessonUseCase? v;
  b;
  c;
  d;
  e;
  f;
  g;
  h;
  i;
  j;
  k;
  l;
  m;
  n;
  o;
  p;
  q;
  r;
  s;
  t;
  u;
  v;
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
  // Đăng ký CourseProgressService
  sl.registerLazySingleton(() => CourseProgressService(sl()));
  // Đăng ký ContentTestService
  sl.registerLazySingleton(() => ContentTestService(sl()));
  // Đăng ký CommentLessonService
  sl.registerLazySingleton(() => CommentLessonService(sl()));
  // Đăng ký PaymentService
  sl.registerLazySingleton(() => PaymentService(sl()));
  sl.registerLazySingleton(() => DiscountService(sl()));
  // Đăng ký DayStreakService
  sl.registerLazySingleton<DayStreakService>(
    () => DayStreakService(
      dio: sl(),
    ),
  );
  // Đăng ký TeachingStaffService
  sl.registerLazySingleton(() => TeachingStaffService(sl()));
  // Đăng ký RecentLessonService
  sl.registerLazySingleton(() => RecentLessonService(sl()));
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

  // Đăng ký CourseProgressRepository
  sl.registerLazySingleton<CourseProgressRepository>(() =>
      CourseProgressRepositoryImpl(
          courseProgressService: sl<CourseProgressService>()));

  // Đăng ký ContentTestRepository
  sl.registerLazySingleton<ContentTestRepository>(() =>
      ContentTestRepositoryImpl(contentTestService: sl<ContentTestService>()));

  // Đăng ký CommentLessonRepository
  sl.registerLazySingleton<CommentLessonRepository>(() =>
      CommentLessonRepositoryImpl(
          commentLessonService: sl<CommentLessonService>()));

  // Đăng ký TestSubmissionRepository
  sl.registerLazySingleton<TestSubmissionRepository>(
      () => TestSubmissionRepositoryImpl(sl<CourseProgressService>()));

  // Đăng ký PaymentRepository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(paymentService: sl<PaymentService>()),
  );
  sl.registerLazySingleton<DiscountRepository>(
    () => DiscountRepositoryImpl(discountService: sl<DiscountService>()),
  );

  // Đăng ký TeachingStaffRepository
  sl.registerLazySingleton<TeachingStaffRepository>(() =>
      TeachingStaffRepositoryImpl(
          teachingStaffService: sl<TeachingStaffService>()));

  // Đăng ký DayStreakRepository
  sl.registerLazySingleton<DayStreakRepository>(
    () => DayStreakRepositoryImpl(
      dayStreakService: sl(),
    ),
  );

  // Đăng ký RecentLessonRepository
  sl.registerLazySingleton<RecentLessonRepository>(
    () => RecentLessonRepositoryImpl(sl<RecentLessonService>()),
  );
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
  // Course Progress
  sl.registerLazySingleton(
      () => AddCourseProgressUseCase(sl<CourseProgressRepository>()));
  sl.registerLazySingleton(
      () => UnlockNextLessonUseCase(sl<CourseProgressRepository>()));
  // Content Test
  sl.registerLazySingleton(
      () => ContentTestUseCase(sl<ContentTestRepository>()));
  // Comment Lesson
  sl.registerLazySingleton(
      () => CommentLessonUseCase(sl<CommentLessonRepository>()));
  // Test Submission
  sl.registerLazySingleton(
      () => TestSubmissionUseCase(sl<TestSubmissionRepository>()));
  // Payment
  sl.registerLazySingleton(() => PaymentUseCase(sl<PaymentRepository>()));

  // UseCases
  sl.registerLazySingleton(
    () => DiscountUseCase(sl<DiscountRepository>()),
  );

  // Đăng ký các usecase liên quan đến Day Streak
  sl.registerLazySingleton<GetUserDayStreakUseCase>(
    () => GetUserDayStreakUseCase(
      sl(),
    ),
  );

  sl.registerLazySingleton<IsActiveDateUseCase>(
    () => IsActiveDateUseCase(
      sl(),
    ),
  );

  sl.registerLazySingleton<GetActiveCountInMonthUseCase>(
    () => GetActiveCountInMonthUseCase(
      sl(),
    ),
  );

  sl.registerLazySingleton<GetActiveCountInWeekUseCase>(
    () => GetActiveCountInWeekUseCase(
      sl(),
    ),
  );

  sl.registerLazySingleton<GetWeekStartDateUseCase>(
    () => GetWeekStartDateUseCase(),
  );

  // Đăng ký TeachingStaffUseCase
  sl.registerLazySingleton(
      () => TeachingStaffUseCase(sl<TeachingStaffRepository>()));

  // Đăng ký RecentLessonUseCase
  sl.registerLazySingleton(
    () => RecentLessonUseCase(sl<RecentLessonRepository>()),
  );
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

  // Đăng ký MyCourseController
  sl.registerLazySingleton<MyCourseController>(() {
    final courseLessonUseCase = sl<CourseLessonUseCase>();
    final recentLessonUseCase = sl<RecentLessonUseCase>();
    
    print('🔍 Đăng ký MyCourseController');
    print('✅ courseLessonUseCase: $courseLessonUseCase');
    print('✅ recentLessonUseCase: $recentLessonUseCase');
    
    return MyCourseController(
      courseLessonUseCase: courseLessonUseCase,
      recentLessonUseCase: recentLessonUseCase,
    );
  });

  // Đăng ký CourseProgressController
  sl.registerLazySingleton<CourseProgressController>(
    () => CourseProgressController(
      addCourseProgressUseCase: sl<AddCourseProgressUseCase>(),
      unlockNextLessonUseCase: sl<UnlockNextLessonUseCase>(),
    ),
  );

  // Đăng ký TestSubmissionController
  sl.registerLazySingleton<TestSubmissionController>(
    () => TestSubmissionController(
      testSubmissionUseCase: sl<TestSubmissionUseCase>(),
    ),
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

  sl.registerLazySingleton<PaymentController>(
    () => PaymentController(
      paymentUseCase: sl<PaymentUseCase>(),
    ),
  );

  // Controllers
  sl.registerLazySingleton<DiscountController>(
    () => DiscountController(discountUseCase: sl<DiscountUseCase>()),
  );

  // Đăng ký TeachingStaffController
  sl.registerLazySingleton<TeachingStaffController>(
    () => TeachingStaffController(),
  );

  // Đăng ký DayStreakController
  sl.registerLazySingleton<DayStreakController>(
    () => DayStreakController(
      getUserDayStreakUseCase: sl(),
      isActiveDateUseCase: sl(),
      getActiveCountInMonthUseCase: sl(),
      getActiveCountInWeekUseCase: sl(),
      getWeekStartDateUseCase: sl(),
    ),
  );
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
