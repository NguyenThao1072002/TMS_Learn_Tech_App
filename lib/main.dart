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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

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
    return MaterialApp(
      title: 'TMS Learn Tech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: false,
        ),
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalKey<NavigatorState>(),
      routes: {
        '/teaching_staff': (context) => const TeachingStaffScreen(),
        '/about_us': (context) => const AboutUsScreen(),
      },
      // Flow chọn màn hình hiển thị:
      // 1. Nếu chưa xem onboarding -> hiển thị OnboardingScreen
      // 2. Nếu đã xem onboarding nhưng chưa đăng nhập -> hiển thị LoginScreen
      // 3. Nếu đã xem onboarding và đã đăng nhập -> hiển thị HomeScreen
      home: showOnboarding
          ? const OnboardingScreen()
          : (isLoggedIn ? HomeScreen() : LoginScreen()),
    );
  }
}
