import 'package:tms_app/domain/repositories/account_repository.dart';

class ForgotPasswordUseCase {
  final AccountRepository accountRepository;

  ForgotPasswordUseCase(this.accountRepository);

  // Lấy thông tin người dùng từ repository
  Future<Map<String, String?>> getUserData() async {
    try {
      final userData = await accountRepository.getUserData();

      // Kiểm tra nếu dữ liệu người dùng không rỗng
      if (userData.isEmpty ||
          userData['email'] == null ||
          userData['phone'] == null) {
        throw Exception('Không có thông tin người dùng.');
      }

      return userData;
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu người dùng: $e');
    }
  }

  // Gửi yêu cầu quên mật khẩu và nhận OTP
  Future<bool> requestForgotPasswordOtp(String email) async {
    try {
      return await accountRepository.forgotPassword(email);
    } catch (e) {
      throw Exception('Lỗi khi gửi yêu cầu đặt lại mật khẩu: $e');
    }
  }

  // Gửi OTP qua email để xác thực
  Future<bool> sendOtpToEmail(String email) async {
    try {
      return await accountRepository.sendOtpToEmail({'email': email});
    } catch (e) {
      throw Exception('Lỗi khi gửi mã OTP: $e');
    }
  }

  // Xác thực mã OTP đã nhập
  Future<bool> verifyOtp(String otp, String email) async {
    try {
      final result = await accountRepository.verifyOtp({
        'otp': otp,
        'email': email,
        'type': 'FORGOT',
      });

      return result;
    } catch (e) {
      throw Exception('Lỗi khi xác thực mã OTP: $e');
    }
  }

  // Cập nhật mật khẩu mới sau khi xác thực OTP
  Future<bool> updatePassword(String newPassword,
      {required String email, required String otp}) async {
    try {
      return await accountRepository.updatePassword({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
        'type': 'FORGOT'
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật mật khẩu: $e');
    }
  }
}
