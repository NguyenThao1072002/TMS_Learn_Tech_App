import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/screens/login/verify_email_screen.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import '../../core/constants/messages.dart';
import '../../core/di/service_locator.dart';
import '../../domain/usecases/login_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';

class LoginController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LoginUseCase loginUseCase;

  // Khóa cho SharedPreferences
  static const String KEY_SAVED_EMAIL = 'saved_email';
  static const String KEY_SAVED_PASSWORD = 'saved_password';
  static const String KEY_REMEMBER_ME = 'remember_me';
  static const String KEY_LAST_LOGIN = 'last_login';

  LoginController({required this.loginUseCase});

  // Phương thức đăng nhập
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await loginUseCase.call(identifier, password);

      if (response != null) {
        // In token JWT ra console để test với Postman
        printJwtToken();

        // Đăng nhập thành công
        return {
          'success': true,
          'message': 'Đăng nhập thành công!',
          'data': response
        };
      } else {
        // Đăng nhập thất bại, ánh xạ lỗi cụ thể từ server (mô phỏng)
        // Trong thực tế, các lỗi này nên được trả về từ server API

        // Giả định phân tích lỗi
        Map<String, String> fieldErrors = {};

        // Kiểm tra định dạng email/số điện thoại
        if (identifier.contains('@')) {
          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
              .hasMatch(identifier)) {
            fieldErrors['email'] = 'Định dạng email không hợp lệ';
          } else if (RegExp(r'^[0-9]').hasMatch(identifier.split('@')[0])) {
            fieldErrors['email'] = 'Email không được bắt đầu bằng số';
          } else {
            fieldErrors['email'] = 'Email chưa được đăng ký';
          }
        } else if (RegExp(r'^(?:\+84|84|0)[0-9]{9,10}$').hasMatch(identifier)) {
          fieldErrors['email'] = 'Số điện thoại chưa được đăng ký';
        } else {
          fieldErrors['email'] =
              'Email hoặc số điện thoại không đúng định dạng';
        }

        // Kiểm tra mật khẩu
        if (password.length < 6) {
          fieldErrors['password'] = 'Mật khẩu phải có ít nhất 6 ký tự';
        } else if (!RegExp(r'[a-zA-Z]').hasMatch(password) ||
            !RegExp(r'[0-9]').hasMatch(password)) {
          fieldErrors['password'] = 'Mật khẩu phải chứa cả chữ và số';
        } else {
          fieldErrors['password'] = 'Mật khẩu không chính xác';
        }

        return {
          'success': false,
          'message': 'Thông tin đăng nhập không chính xác',
          'errors': fieldErrors
        };
      }
    } catch (error) {
      // Lỗi kết nối hoặc lỗi server
      return {
        'success': false,
        'message': 'Đăng nhập thất bại: $error',
        'errors': {
          'email':
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.'
        }
      };
    }
  }

  // Lưu thông tin đăng nhập vào SharedPreferences
  Future<void> saveLoginInfo(
    String email,
    String password,
    bool remember,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu thông tin đăng nhập nếu người dùng chọn "Nhớ mật khẩu"
    if (remember) {
      await prefs.setString(KEY_SAVED_EMAIL, email);
      await prefs.setString(KEY_SAVED_PASSWORD, password);
      await prefs.setBool(KEY_REMEMBER_ME, true);
      await prefs.setString(KEY_LAST_LOGIN, DateTime.now().toIso8601String());

      // Ghi log
      debugPrint('Đã lưu thông tin đăng nhập cho: $email');
    } else {
      // Xóa thông tin đăng nhập nếu không chọn "Nhớ mật khẩu"
      await prefs.remove(KEY_SAVED_EMAIL);
      await prefs.remove(KEY_SAVED_PASSWORD);
      await prefs.remove(KEY_REMEMBER_ME);
      await prefs.remove(KEY_LAST_LOGIN);

      // Ghi log
      debugPrint('Đã xóa thông tin đăng nhập đã lưu');
    }
  }

  // Tải thông tin đăng nhập đã lưu từ SharedPreferences
  Future<void> loadSavedLoginInfo(
    TextEditingController emailController,
    TextEditingController passwordController,
    Function(bool) setRemember,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(KEY_SAVED_EMAIL) ?? "";
      final savedPassword = prefs.getString(KEY_SAVED_PASSWORD) ?? "";
      final remember = prefs.getBool(KEY_REMEMBER_ME) ?? false;
      final lastLogin = prefs.getString(KEY_LAST_LOGIN) ?? "";

      if (remember && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
        // Kiểm tra xem thông tin đăng nhập có còn hiệu lực không (dưới 30 ngày)
        if (lastLogin.isNotEmpty) {
          final lastLoginDate = DateTime.parse(lastLogin);
          final now = DateTime.now();
          final difference = now.difference(lastLoginDate);

          // Nếu thông tin đăng nhập đã lưu quá 30 ngày, xóa thông tin
          if (difference.inDays > 30) {
            await prefs.remove(KEY_SAVED_EMAIL);
            await prefs.remove(KEY_SAVED_PASSWORD);
            await prefs.remove(KEY_REMEMBER_ME);
            await prefs.remove(KEY_LAST_LOGIN);
            debugPrint('Thông tin đăng nhập đã hết hạn (quá 30 ngày)');
            return;
          }
        }

        // Điền thông tin đăng nhập vào form
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        setRemember(remember);

        debugPrint('Đã tải thông tin đăng nhập cho: $savedEmail');
      }
    } catch (e) {
      debugPrint('Lỗi khi tải thông tin đăng nhập: $e');
    }
  }

  // Chuyển hướng đến màn hình chính sau khi đăng nhập thành công
  void navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // Đăng nhập với Google
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ToastHelper.showErrorToast(AppMessages.googleLoginCancelled);
        return;
      }

      // Gửi googleAuth.idToken lên server để xác thực
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // TODO: Gửi googleAuth.idToken lên server để xác thực
      // Xử lý như login thường nếu có
    } catch (error) {
      ToastHelper.showErrorToast("${AppMessages.googleLoginError}$error");
    }
  }

  // Đăng xuất người dùng
  Future<void> logout(BuildContext context) async {
    try {
      // 1. Lấy trạng thái "Nhớ mật khẩu"
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(KEY_REMEMBER_ME) ?? false;

      // 2. Xóa token và thông tin người dùng trong SharedPreferences
      await SharedPrefs.removeJwtToken();
      await prefs.remove(SharedPrefs.KEY_USER_EMAIL);
      await prefs.remove(SharedPrefs.KEY_USER_PHONE);
      await prefs.remove(SharedPrefs.KEY_USER_ID);
      await prefs.remove(SharedPrefs.KEY_REFRESH_TOKEN);
      await prefs.remove(SharedPrefs.KEY_USER_FULLNAME);
      await prefs.remove(SharedPrefs.KEY_USER_IMAGE);

      // 3. Xóa thông tin đăng nhập nếu không chọn "Nhớ mật khẩu"
      if (!rememberMe) {
        await prefs.remove(KEY_SAVED_EMAIL);
        await prefs.remove(KEY_SAVED_PASSWORD);
        await prefs.remove(KEY_REMEMBER_ME);
        await prefs.remove(KEY_LAST_LOGIN);
      }

      // 4. Đăng xuất khỏi Google nếu đã đăng nhập bằng Google
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
      }

      // 5. Hiển thị thông báo thành công
      ToastHelper.showSuccessToast("Đăng xuất thành công");

      // 6. Điều hướng đến màn hình đăng nhập và xóa tất cả màn hình trước đó
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route trước đó
      );
    } catch (error) {
      ToastHelper.showErrorToast("Đã xảy ra lỗi khi đăng xuất: $error");
    }
  }

  // Điều hướng đến màn hình quên mật khẩu
  void navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyEmailScreen(
          email: '', // Truyền email từ controller
          controller: ForgotPasswordController(
              accountRepository: sl()), // Khởi tạo controller từ DI
        ),
      ),
    );
  }

  // In JWT Token ra console để sử dụng trong Postman
  Future<void> printJwtToken() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Đợi để đảm bảo token đã được lưu
    final token = await SharedPrefs.getJwtToken();
    if (token != null && token.isNotEmpty) {
      debugPrint(
          '\n=================== JWT TOKEN FOR POSTMAN ===================');
      debugPrint(token);
      debugPrint(
          '===========================================================\n');
    } else {
      debugPrint('Không tìm thấy JWT token!');
    }
  }
}
