import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/screens/homePage/home.dart';
import 'package:tms/screens/login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Kiểm tra token không rỗng & có độ dài hợp lệ
    if (token != null && token.isNotEmpty && token.length > 10) {
      return true; // Token hợp lệ -> Vào HomeScreen
    } else {
      return false; // Không có token -> Yêu cầu đăng nhập lại
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                  child:
                      CircularProgressIndicator()), // Loading khi kiểm tra token
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen(); // Nếu có token hợp lệ, vào HomeScreen
          } else {
            return LoginScreen(); // Nếu không có token hoặc token không hợp lệ, về LoginScreen
          }
        },
      ),
    );
  }
}
