//Chứa logic khởi tạo các dịch vụ và repository.
import 'package:dio/dio.dart';
import 'package:tms_app/data/services/auth_service.dart';
import 'package:tms_app/data/services/user_service.dart';
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import 'package:tms_app/core/localization/app_localization.dart';
import 'package:tms_app/core/theme/app_themes.dart';
import 'package:tms_app/core/widgets/app_connectivity_wrapper.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';
import 'package:tms_app/presentation/controller/my_course/my_course_controller.dart';
import 'package:tms_app/presentation/controller/teaching_staff_controller.dart';
import 'package:tms_app/presentation/controller/theme_controller.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/presentation/screens/homePage/teaching_staff.dart';
import 'package:tms_app/presentation/screens/homePage/about_us.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import 'package:tms_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tms_app/core/DI/service_locator.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool showOnboarding = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _checkLoggedIn();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    setState(() {
      showOnboarding = !hasSeenOnboarding;
    });
  }

  Future<void> _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

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
              initialRoute: '/',
              getPages: [
                GetPage(
                    name: '/',
                    page: () => showOnboarding
                        ? const OnboardingScreen()
                        : (isLoggedIn ? HomeScreen() : LoginScreen())),
                GetPage(
                    name: '/notifications',
                    page: () => const NotificationScreen()),
                GetPage(
                    name: '/teaching_staff',
                    page: () => const TeachingStaffScreen()),
                GetPage(name: '/about_us', page: () => const AboutUsScreen()),
                // Add other routes as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
