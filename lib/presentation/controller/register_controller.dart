import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/domain/usecases/send_otp_to_email_usecase.dart';
import 'package:tms_app/domain/usecases/verify_register_otp_usecase.dart';
import 'package:tms_app/presentation/screens/login/register_otp_screen.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';

class RegisterController {
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

        // Hiển thị thông báo toast thành công
        Fluttertoast.showToast(
          msg: response['message'] ?? "Mã OTP đã được gửi!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppStyles.successToastBackgroundColor,
          textColor: AppStyles.toastTextColor,
          fontSize: AppStyles.toastFontSize,
        );

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
        // Hiển thị thông báo toast thất bại
        Fluttertoast.showToast(
          msg: response != null
              ? (response['message'] ?? "Đăng ký thất bại!")
              : "Đăng ký thất bại! Vui lòng thử lại.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppStyles.errorToastBackgroundColor,
          textColor: AppStyles.toastTextColor,
          fontSize: AppStyles.toastFontSize,
        );
      }
    } catch (error) {
      // Hiển thị thông báo lỗi nếu có exception xảy ra
      Fluttertoast.showToast(
        msg: "Đăng ký thất bại! $error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: AppStyles.errorToastBackgroundColor,
        textColor: AppStyles.toastTextColor,
        fontSize: AppStyles.toastFontSize,
      );
    }
  }

  // Phương thức xác thực OTP cho đăng ký
  Future<bool> verifyOtp(String otp, String email) async {
    // Sử dụng UseCase thay vì gọi trực tiếp repository
    return await verifyRegisterOtpUseCase.call(otp, email);
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
}
