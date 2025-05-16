import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/shared_prefs.dart';

class AuthService {
  final Dio dio;
  final String baseUrl =
      '${Constants.BASE_URL}/api/account'; // Thêm prefix /api vào baseUrl

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

  // Kiểm tra mật khẩu hiện tại trước khi đổi
  Future<bool> verifyCurrentPassword(
      String email, String currentPassword) async {
    try {
      // Tạo body request chứa email và mật khẩu hiện tại
      final loginBody = {'email': email, 'password': currentPassword};

      // Gọi API login để kiểm tra mật khẩu hiện tại
      final response = await dio.post(
        '$baseUrl/dang-nhap',
        data: jsonEncode(loginBody),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Nếu login thành công, mật khẩu hiện tại đúng
      return response.statusCode == 200;
    } catch (e) {
      // Nếu có lỗi (như thông tin đăng nhập không đúng), trả về false
      return false;
    }
  }

  // Change Password API (requires authentication)
  Future<bool> changePassword(Map<String, dynamic> body) async {
    try {
      // Get JWT token from SharedPreferences
      final token = await SharedPrefs.getJwtToken();

      // Lấy SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      final email = prefs.getString(SharedPrefs.KEY_USER_EMAIL) ?? '';

      if (token == null || token.isEmpty) {
        return false;
      }

      if (userId == null || userId.isEmpty) {
        return false;
      }

      // Kiểm tra mật khẩu hiện tại trước khi cho phép đổi
      final isCurrentPasswordValid =
          await verifyCurrentPassword(email, body['currentPassword']);

      if (!isCurrentPasswordValid) {
        return false; // Trả về false nếu mật khẩu hiện tại không đúng
      }

      final endpoint =
          '${Constants.BASE_URL}/api/account/change-password/$userId';

      final response = await dio.put(
        endpoint,
        data: jsonEncode(body),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }),
      );

      // Kiểm tra cả status code và nội dung response
      if (response.statusCode == 200) {
        // Kiểm tra thêm message từ API
        if (response.data != null &&
            response.data['message'] != null &&
            response.data['message']
                .toString()
                .toLowerCase()
                .contains('sai mật khẩu')) {
          print(
              'API trả về lỗi sai mật khẩu nhưng với status 200: ${response.data}');
          return false;
        }

        // Nếu API trả về thành công, cập nhật mật khẩu trong SharedPreferences
        await _updatePasswordData(body['newPassword']);

        // Đảm bảo rằng mật khẩu đã được lưu đúng
        await _clearOldPasswordData();

        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Change password failed: ${e.response?.data}');
      }
      return false;
    }
  }

  // Cập nhật thông tin mật khẩu trong SharedPreferences
  Future<void> _updatePasswordData(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Xóa tất cả các thông tin đăng nhập đã lưu
      await prefs.remove('saved_password');
      await prefs.remove('saved_email');
      await prefs.remove('remember_me');
      await prefs.remove('password_cached');
      await prefs.remove('password_last_changed');
      await prefs.remove('last_login');

      // Lưu thời gian thay đổi mật khẩu
      await prefs.setString(
          'password_last_changed', DateTime.now().toIso8601String());
    } catch (e) {
      print("Lỗi khi xóa thông tin đăng nhập: $e");
    }
  }

  // Xóa thông tin mật khẩu cũ và đảm bảo rằng tất cả thông tin đăng nhập được xóa
  Future<void> _clearOldPasswordData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Xóa các thông tin đăng nhập
      await prefs.remove('password_cached');
      await prefs.remove('saved_password');
      await prefs.remove('saved_email');
      await prefs.setBool('remember_me', false);
      await prefs.remove('last_login');
    } catch (e) {
      print("Lỗi khi xóa thông tin đăng nhập: $e");
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
