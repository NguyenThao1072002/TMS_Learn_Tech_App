//chứa cấu trúc và điều hướng UD
import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/presentation/screens/blog/blog_list.dart';
import 'package:tms_app/presentation/screens/document/document_list_screen.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/presentation/screens/homePage/teaching_staff.dart';
import 'package:tms_app/presentation/screens/homePage/about_us.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/presentation/controller/my_course/my_course_controller.dart';
import 'package:tms_app/core/widgets/app_connectivity_wrapper.dart';
import 'package:tms_app/presentation/controller/teaching_staff_controller.dart';
import 'package:tms_app/presentation/controller/theme_controller.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';
import 'package:tms_app/core/theme/app_themes.dart';
import 'package:tms_app/core/localization/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tms_app/presentation/controller/notification_controller.dart';
import 'package:tms_app/domain/repositories/notification_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo Service Locator được thiết lập đúng cách
  try {
    setupLocator();
    print('Service Locator đã được thiết lập thành công');

    // Verify AuthManager is registered properly
    final authManager = GetIt.instance<AuthManager>();
    print('AuthManager successfully retrieved: ${authManager != null}');

    // Initialize NotificationController with GetX
    try {
      final notificationController = sl<NotificationController>();
      Get.put(notificationController, permanent: true);
      // print('NotificationController successfully initialized with GetX');

      // Preload notifications
      await notificationController.loadNotifications();
      // print('Notifications preloaded');
    } catch (e) {
      print('Error initializing NotificationController: $e');
    }
  } catch (e) {
    print('Lỗi khi thiết lập Service Locator: $e');
  }

  // Disable debug paint size
  debugPaintSizeEnabled = false;

  // Kiểm tra xem người dùng đã xem onboarding và đã đăng nhập chưa
  final prefs = await SharedPreferences.getInstance();
  bool hasCompletedOnboarding = false;
  try {
    hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
  } catch (e) {
    // If there's an error reading the preference, default to false
    hasCompletedOnboarding = false;
  }

  final bool showOnboarding = !hasCompletedOnboarding;
  final String? token = prefs.getString('auth_token');
  final bool isLoggedIn =
      token != null && token.isNotEmpty && token.length > 10;

  runApp(MyApp(
    showOnboarding: showOnboarding,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isLoggedIn;
  final AccountRepository accountRepository = sl<AccountRepository>();

  MyApp({
    Key? key,
    required this.showOnboarding,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy AuthManager từ service locator
    AuthManager authManager;
    try {
      authManager = GetIt.instance<AuthManager>();
    } catch (e) {
      print('Lỗi khi lấy AuthManager từ GetIt: $e');
      // Fallback to a new instance if retrieval fails
      authManager = AuthManager();
    }

    return MultiProvider(
      providers: [
        // Cung cấp UnifiedSearchController thông qua Provider
        ChangeNotifierProvider<UnifiedSearchController>(
          create: (_) => sl<UnifiedSearchController>(),
        ),
        ChangeNotifierProvider(create: (_) => MyCourseController()),
        // Thêm TeachingStaffController vào providers
        ChangeNotifierProvider(create: (_) => TeachingStaffController()),
        // Thêm ThemeController và LanguageController
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        // Thêm các provider khác nếu cần
      ],
      child: Consumer2<ThemeController, LanguageController>(
        builder: (context, themeController, languageController, child) {
          return AppConnectivityWrapper(
            child: GetMaterialApp(
              title: 'TMS Learn Tech',
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeController.themeMode,
              debugShowCheckedModeBanner: false,
              navigatorKey: authManager.navigatorKey,
              locale: languageController.currentLocale,
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('vi', ''), // Vietnamese
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              getPages: [
                GetPage(
                    name: '/teaching_staff',
                    page: () => const TeachingStaffScreen()),
                GetPage(name: '/about_us', page: () => const AboutUsScreen()),
              ],
              // Flow chọn màn hình hiển thị:
              // 1. Nếu chưa xem onboarding -> hiển thị OnboardingScreen
              // 2. Nếu đã xem onboarding nhưng chưa đăng nhập -> hiển thị LoginScreen
              // 3. Nếu đã xem onboarding và đã đăng nhập -> hiển thị HomeScreen
              home: showOnboarding
                  ? const OnboardingScreen()
                  : (isLoggedIn ? HomeScreen() : LoginScreen()),
            ),
          );
        },
      ),
    );
  }
}

// Placeholder home screen, replace with your actual home screen
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TMS App Home Screen'),
      ),
    );
  }
}
