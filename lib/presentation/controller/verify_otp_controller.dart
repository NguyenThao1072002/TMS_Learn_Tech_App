import 'package:get/get.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';

class VerifyOtpController extends GetxController {
  final ForgotPasswordController forgotPasswordController;

  // Các biến để lưu trữ trạng thái
  var errorMessage = ''.obs;
  var isLoading = false.obs;

  // Khởi tạo controller
  VerifyOtpController({required this.forgotPasswordController});

  // Gửi OTP
  Future<bool> sendOtp(String identifier) async {
    try {
      isLoading.value = true;
      // Gọi phương thức từ ForgotPasswordController để gửi OTP
      final result = await forgotPasswordController.sendOtpToEmail(identifier);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // Xác thực OTP
  Future<bool> verifyOtp(String identifier, String otp) async {
    try {
      isLoading.value = true;
      // Gọi phương thức từ ForgotPasswordController để xác thực OTP
      final result = await forgotPasswordController.verifyOtp(identifier, otp);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // Gửi lại OTP nếu người dùng không nhận được
  Future<bool> resendOtp(String identifier) async {
    return await sendOtp(identifier);
  }
}
