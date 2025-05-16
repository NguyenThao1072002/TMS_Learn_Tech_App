import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/shared_prefs.dart';

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

        // Debug: In ra toàn bộ response để kiểm tra
        print('===== LOGIN RESPONSE =====');
        print(jsonEncode(data));
        print('=========================');

        final userInfo = data['responsiveDTOJWT'];

        // Debug: In ra thông tin userInfo để kiểm tra
        print('===== USER INFO =====');
        print(jsonEncode(userInfo));
        print('====================');

        final userEmail = userInfo['email'] ?? '';
        final userPhone = userInfo['phone'] ?? '';
        final userFullName = userInfo['fullname'] ?? '';

        // Xử lý URL ảnh
        final userImage = _processImageUrl(userInfo, data);

        // Lấy userId từ userInfo
        final userId = userInfo['id'] ?? userInfo['userId'] ?? '';

        // Lấy JWT token và refreshToken
        final jwtToken = data['jwt'];
        final refreshToken = data['refreshToken'];

        // Save user info và tokens to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(SharedPrefs.KEY_USER_EMAIL, userEmail);
        await prefs.setString(SharedPrefs.KEY_USER_PHONE, userPhone);
        await prefs.setString(SharedPrefs.KEY_USER_ID, userId.toString());
        await prefs.setString(SharedPrefs.KEY_USER_FULLNAME, userFullName);
        await prefs.setString(SharedPrefs.KEY_USER_IMAGE, userImage);

        // Lưu JWT token và refreshToken sử dụng SharedPrefs
        await SharedPrefs.saveJwtToken(jwtToken);
        await prefs.setString(
            SharedPrefs.KEY_REFRESH_TOKEN, refreshToken ?? '');

        // Thêm log để kiểm tra
        print('Saved userId to SharedPreferences: $userId');
        print('Saved JWT token to SharedPreferences: $jwtToken');
        print('Saved user fullname: $userFullName');
        print('Saved user image: $userImage');

        return {
          'jwt': jwtToken,
          'refreshToken': refreshToken,
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

  // Phương thức xử lý URL ảnh từ response API
  String _processImageUrl(
      Map<String, dynamic> userInfo, Map<String, dynamic> data) {
    // Debug: Kiểm tra cụ thể trường image
    print('Image field: ${userInfo['image']}');

    // Thử các trường khác có thể chứa URL ảnh
    String userImage = '';
    final possibleImageFields = [
      'image',
      'avatar',
      'profileImage',
      'imageUrl',
      'avatarUrl',
      'profile_image'
    ];
    for (var field in possibleImageFields) {
      if (userInfo.containsKey(field) &&
          userInfo[field] != null &&
          userInfo[field].toString().isNotEmpty) {
        print('Found image in field: $field = ${userInfo[field]}');
        if (userImage.isEmpty) {
          userImage = userInfo[field].toString();
        }
      }
    }

    // Nếu vẫn không tìm thấy
    if (userImage.isEmpty) {
      userImage = userInfo['image'] ?? '';
    }

    // Kiểm tra nếu ảnh trong data ở cấp cao hơn
    if (userImage.isEmpty &&
        data.containsKey('image') &&
        data['image'] != null) {
      userImage = data['image'].toString();
      print('Found image in root data: $userImage');
    }

    // Thêm prefix cho URL ảnh nếu cần
    if (userImage.isNotEmpty && !userImage.startsWith('http')) {
      userImage = 'https://$userImage';
      print('Modified image URL: $userImage');
    }

    return userImage;
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
      'email': prefs.getString(SharedPrefs.KEY_USER_EMAIL),
      'phone': prefs.getString(SharedPrefs.KEY_USER_PHONE),
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

  // Change Password API (requires authentication)
  Future<bool> changePassword(Map<String, dynamic> body) async {
    try {
      // Get JWT token from SharedPreferences
      final token = await SharedPrefs.getJwtToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID) ?? '1';

      if (token == null || token.isEmpty) {
        print("JWT token not found. Please login again.");
        return false;
      }

      // Tách và sửa lại URL để tránh trùng lặp "/account"
      final baseUrlWithoutAccount = Constants.BASE_URL; // Không thêm /account
      final response = await dio.put(
        '$baseUrlWithoutAccount/api/account/change-password/$userId',
        data: jsonEncode(body),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }),
      );

      print('Change password response: ${response.statusCode}');
      print('Response data: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print("Error changing password: $e");

      // Print detailed error information
      if (e is DioException && e.response != null) {
        print("Error status code: ${e.response?.statusCode}");
        print("Error data: ${e.response?.data}");
      }

      return false;
    }
  }

  // Login with Google
  Future<Map<String, dynamic>?> loginWithGoogle(
      Map<String, dynamic> body) async {
    try {
      // Gọi API endpoint dành cho đăng nhập Google
      final response = await dio.post(
        '$baseUrl/google-login',
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Debug: In ra toàn bộ response để kiểm tra
        print('===== GOOGLE LOGIN RESPONSE =====');
        print(jsonEncode(data));
        print('=================================');

        final userInfo = data['responsiveDTOJWT'];
        final userEmail = userInfo['email'] ?? '';
        final userPhone = userInfo['phone'] ?? '';
        final userFullName = userInfo['fullname'] ?? '';
        final userImage = _processImageUrl(userInfo, data);
        final userId = userInfo['id'] ?? userInfo['userId'] ?? '';
        final jwtToken = data['jwt'];
        final refreshToken = data['refreshToken'];

        // Lưu thông tin người dùng và token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(SharedPrefs.KEY_USER_EMAIL, userEmail);
        await prefs.setString(SharedPrefs.KEY_USER_PHONE, userPhone);
        await prefs.setString(SharedPrefs.KEY_USER_ID, userId.toString());
        await prefs.setString(SharedPrefs.KEY_USER_FULLNAME, userFullName);
        await prefs.setString(SharedPrefs.KEY_USER_IMAGE, userImage);
        await SharedPrefs.saveJwtToken(jwtToken);
        await prefs.setString(
            SharedPrefs.KEY_REFRESH_TOKEN, refreshToken ?? '');

        return {
          'jwt': jwtToken,
          'refreshToken': refreshToken,
          'userInfo': userInfo,
        };
      } else {
        print('Google login failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Google login failed: $e");
      return null;
    }
  }
}
