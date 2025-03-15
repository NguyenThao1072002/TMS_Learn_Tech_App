import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountServices {
  static const String baseUrl =
      'http://103.166.143.198:8080/account'; // API cơ bản

  // Hàm đăng nhập
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dang-nhap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Lấy thông tin user từ API
        final userInfo = data['responsiveDTOJWT'];
        final userEmail = userInfo['email'] ?? '';
        final userPhone = userInfo['phone'] ?? '';

        // Lưu email và số điện thoại vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userEmail);
        await prefs.setString('user_phone', userPhone);

        return {
          'jwt': data['jwt'],
          'refreshToken': data['refreshToken'],
          'userInfo': data['responsiveDTOJWT'],
        }; // Trả về một đối tượng chứa tất cả các thông tin cần thiết
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }

  // Hàm đăng ký
  static Future<Map<String, dynamic>?> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dang-ky'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
        //       body: jsonEncode({
        // 'name': name,
        // 'email': email,
        // phone: 'phone',
        // 'password': password
        //}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'jwt': data['jwt'],
          'refreshToken': data['refreshToken'],
          'userInfo': data['responsiveDTOJWT'],
        }; // Trả về một đối tượng chứa tất cả các thông tin cần thiết
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  // Hàm lấy thông tin user từ SharedPreferences
  static Future<Map<String, String?>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'phone': prefs.getString('user_phone'),
    };
  }

  // Hàm gửi OTP đến email
  static Future<bool> sendOtpToEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true; // Gửi OTP thành công
      } else {
        return false; // Gửi OTP thất bại
      }
    } catch (e) {
      print("Lỗi gửi OTP: $e");
      return false;
    }
  }
}
