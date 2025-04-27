import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/presentation/screens/blog/blog_list.dart';
import 'package:tms_app/presentation/screens/document/document_list_screen.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AccountRepository accountRepository = sl<AccountRepository>();

  MyApp({Key? key}) : super(key: key);

  Future<bool> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty && token.length > 10;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TMS App',
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalKey<NavigatorState>(),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
