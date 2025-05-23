import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/domain/usecases/send_otp_to_email_usecase.dart';
import 'package:tms_app/domain/usecases/verify_register_otp_usecase.dart';
import 'package:tms_app/presentation/screens/login/register_otp_screen.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/presentation/controller/login/forgot_password_controller.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/screens/onboarding/onboarding_screen.dart';

class RegisterController {
  // Khóa cho SharedPreferences - giống LoginController
  static const String KEY_SAVED_EMAIL = 'saved_email';
  static const String KEY_SAVED_PASSWORD = 'saved_password';
  static const String KEY_REMEMBER_ME = 'remember_me';
  static const String KEY_LAST_LOGIN = 'last_login';

  final RegisterUseCase registerUseCase;
  final AccountRepository accountRepository;
  late final ForgotPasswordController otpController;
  late final VerifyRegisterOtpUseCase verifyRegisterOtpUseCase;
  late final SendOtpToEmailUseCase sendOtpToEmailUseCase;
  String? _registeredEmail; // Store registered email

  RegisterController({
    required this.registerUseCase,
    required this.accountRepository,
  }) {
    otpController =
        ForgotPasswordController(accountRepository: accountRepository);
    verifyRegisterOtpUseCase = VerifyRegisterOtpUseCase(accountRepository);
    sendOtpToEmailUseCase = SendOtpToEmailUseCase(accountRepository);
  }

  Future<void> register(
    String fullname,
    String email,
    String birthday,
    String phone,
    String password,
    BuildContext context,
  ) async {
    try {
      // Gọi usecase để thực hiện đăng ký
      final response = await registerUseCase.call(
        fullname,
        email,
        birthday,
        phone,
        password,
      );

      if (response != null && response['status'] == 200) {
        // Store email for OTP verification
        _registeredEmail = email;

        // Use ToastHelper instead of direct Fluttertoast
        ToastHelper.showSuccessToast(
            response['message'] ?? "Mã OTP đã được gửi!");

        // Chuyển hướng tới màn hình xác thực OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterOtpScreen(
              email: email,
              controller: this,
            ),
          ),
        );
      } else {
        // Use ToastHelper instead of direct Fluttertoast
        ToastHelper.showErrorToast(response != null
            ? (response['message'] ?? "Đăng ký thất bại!")
            : "Đăng ký thất bại! Vui lòng thử lại.");
      }
    } catch (error) {
      // Use ToastHelper instead of direct Fluttertoast
      ToastHelper.showErrorToast("Đăng ký thất bại! $error");
    }
  }

  // Phương thức xác thực OTP cho đăng ký
  Future<Map<String, dynamic>> verifyOtp(
      String otp, String email, String type) async {
    try {
      // Sử dụng UseCase thay vì gọi trực tiếp repository
      bool success = await verifyRegisterOtpUseCase.call(otp, email, type);
      if (success) {
        return {'success': true, 'message': 'Xác thực OTP thành công!'};
      } else {
        return {
          'success': false,
          'message': 'Mã OTP không chính xác hoặc đã hết hạn.'
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Xác thực thất bại: $error'};
    }
  }

  // Phương thức gửi lại mã OTP
  Future<bool> sendOtpToEmail(String email) async {
    // Sử dụng UseCase thay vì gọi trực tiếp repository
    return await sendOtpToEmailUseCase.call({'identifier': email});
  }

  // Chuyển đến trang chủ sau khi xác thực thành công
  void navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // Chuyển đến màn hình đăng nhập sau khi xác thực OTP thành công
  Future<void> navigateToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa toàn bộ thông tin đăng nhập đã lưu
    await prefs.remove(KEY_SAVED_EMAIL);
    await prefs.remove(KEY_SAVED_PASSWORD);
    await prefs.remove(KEY_REMEMBER_ME);
    await prefs.remove(KEY_LAST_LOGIN);

    // Chuyển đến màn hình đăng nhập
    if (context.mounted) {
      ToastHelper.showSuccessToast('Đăng ký thành công! Vui lòng đăng nhập.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
