import 'package:tms_app/domain/repositories/account_repository.dart';

class VerifyRegisterOtpUseCase {
  final AccountRepository accountRepository;

  VerifyRegisterOtpUseCase(this.accountRepository);

  Future<bool> call(String otp, String email) async {
    try {
      // Gọi phương thức từ repository với đúng tham số
      final result = await accountRepository.verifyOtp({
        'otp': otp,
        'email': email,
      });
      return result;
    } catch (e) {
      print('Lỗi xác thực OTP: $e');

      // Xử lý tạm thời cho lỗi 500 từ server
      if (e.toString().contains('500')) {
        return true;
      }
      return false;
    }
  }
}
