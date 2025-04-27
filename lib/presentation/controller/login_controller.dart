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

class LoginController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LoginUseCase loginUseCase;

  // Khóa cho SharedPreferences
  static const String KEY_SAVED_EMAIL = 'saved_email';
  static const String KEY_SAVED_PASSWORD = 'saved_password';
  static const String KEY_REMEMBER_ME = 'remember_me';
  static const String KEY_AUTH_TOKEN = 'auth_token';
  static const String KEY_USER_INFO = 'user_info';
  static const String KEY_LAST_LOGIN = 'last_login';

  LoginController({required this.loginUseCase});

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

  // Hiển thị thông báo toast
  void showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Đăng nhập với Google
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showToast(AppMessages.googleLoginCancelled, Colors.red);
        return;
      }

      // Gửi googleAuth.idToken lên server để xác thực
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // TODO: Gửi googleAuth.idToken lên server để xác thực
      // Xử lý như login thường nếu có
    } catch (error) {
      showToast("${AppMessages.googleLoginError}$error", Colors.red);
    }
  }

  // Đăng xuất người dùng
  Future<void> logout(BuildContext context) async {
    try {
      // 1. Lấy trạng thái "Nhớ mật khẩu"
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(KEY_REMEMBER_ME) ?? false;

      // 2. Xóa token và thông tin người dùng trong SharedPreferences
      await prefs.remove(KEY_AUTH_TOKEN);
      await prefs.remove(KEY_USER_INFO);

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
      showToast("Đăng xuất thành công", Colors.green);

      // 6. Điều hướng đến màn hình đăng nhập và xóa tất cả màn hình trước đó
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route trước đó
      );
    } catch (error) {
      showToast("Đã xảy ra lỗi khi đăng xuất: $error", Colors.red);
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
}
