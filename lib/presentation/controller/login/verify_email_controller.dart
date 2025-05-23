import 'package:get/get.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class VerifyEmailController extends GetxController {
  final AccountRepository _accountRepository;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  VerifyEmailController({required AccountRepository accountRepository})
      : _accountRepository = accountRepository;

  // Kiểm tra định dạng email có hợp lệ không
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return emailRegex.hasMatch(email);
  }

  // Xác thực mã OTP đã nhập với email
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Xóa thông báo lỗi trước đó

      final result = await _accountRepository.verifyOtp({
        'email': email,
        'otp': otp,
      });

      if (result == null || result == false) {
        errorMessage.value = 'Xác thực thất bại. Vui lòng thử lại.';
        return false;
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Gửi lại mã OTP qua email
  Future<bool> resendOtp(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Xóa thông báo lỗi trước đó

      final result = await _accountRepository.sendOtpToEmail({
        'email': email,
      });

      if (result == null || result == false) {
        errorMessage.value = 'Gửi lại mã thất bại. Vui lòng thử lại.';
        return false;
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
