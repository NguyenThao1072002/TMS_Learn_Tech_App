import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/constants.dart';

class AuthService {
  final Dio dio;
  final String baseUrl =
      '${Constants.BASE_URL}/account'; // Sử dụng URL từ constants

  AuthService(this.dio);

  // Login API
  Future<Map<String, dynamic>?> login(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/dang-nhap',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userInfo = data['responsiveDTOJWT'];
        final userEmail = userInfo['email'] ?? '';
        final userPhone = userInfo['phone'] ?? '';

        // Save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userEmail);
        await prefs.setString('user_phone', userPhone);

        return {
          'jwt': data['jwt'],
          'refreshToken': data['refreshToken'],
          'userInfo': userInfo,
        };
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  // Register API
  Future<Map<String, dynamic>?> register(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/register-generate', // URL cho đăng ký
        data: jsonEncode(body), // Gửi thông tin đăng ký dưới dạng JSON
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Trả về đúng định dạng response từ API
        return {
          'status': data['status'],
          'message': data['message'],
          'data': data['data'],
          'email':
              body['email'], // Trả về email để sử dụng cho OTP verification
        };
      } else {
        print('Registration failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Registration failed: $e");
      return null;
    }
  }

  // Get User Data from SharedPreferences
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'phone': prefs.getString('user_phone'),
    };
  }

  // Send OTP API
  Future<bool> sendOtpToEmail(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/send-otp',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

// // Send OTP to Phone
//   Future<bool> sendOtpToPhone(Map<String, dynamic> body) async {
//     try {
//       final response = await dio.post(
//         '$baseUrl/send-otp-to-phone', // Use the appropriate endpoint for phone OTP
//         data: jsonEncode(body),
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       return response.statusCode ==
//           200; // Return true if OTP is successfully sent
//     } catch (e) {
//       print("Error sending OTP to phone: $e");
//       return false;
//     }
//   }

  // Update Password API
  Future<bool> updatePassword(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/update-password',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return response.statusCode ==
          200; // Return true if password is updated successfully
    } catch (e) {
      print("Error updating password: $e");
      return false;
    }
  }

  // Verify OTP API
  Future<bool> verifyOtp(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/verify-otp',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return response.statusCode ==
          200; // Return true if OTP is verified successfully
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

// Gửi OTP
  Future<bool> sendOtp(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
        '$baseUrl/send-otp',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200; // Trả về true nếu OTP gửi thành công
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }
}
