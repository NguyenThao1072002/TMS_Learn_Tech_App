import 'package:tms_app/domain/repositories/account_repository.dart';

class ForgotPasswordUseCase {
  final AccountRepository accountRepository;

  ForgotPasswordUseCase(this.accountRepository);

  // Lấy thông tin người dùng
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
      // Xử lý lỗi khi không thể lấy dữ liệu người dùng
      throw Exception('Lỗi khi lấy dữ liệu người dùng: $e');
    }
  }

  // Gửi yêu cầu quên mật khẩu
  Future<bool> requestForgotPasswordOtp(String email) async {
    try {
      return await accountRepository.forgotPassword(email);
    } catch (e) {
      throw Exception('Lỗi khi gửi yêu cầu đặt lại mật khẩu: $e');
    }
  }

  // Gửi OTP qua email
  Future<bool> sendOtpToEmail(String email) async {
    try {
      return await accountRepository.sendOtpToEmail({'email': email});
    } catch (e) {
      throw Exception('Lỗi khi gửi mã OTP: $e');
    }
  }

  // Xác thực mã OTP
  Future<bool> verifyOtp(String otp, String email) async {
    try {
      print('ForgotPasswordUseCase: Đang gửi yêu cầu xác thực OTP...');
      print('OTP: $otp, Email: $email');

      final result = await accountRepository.verifyOtp({
        'otp': otp,
        'email': email,
        'type': 'FORGOT',
      });

      print('ForgotPasswordUseCase: Kết quả xác thực OTP: $result');
      return result;
    } catch (e) {
      print('ForgotPasswordUseCase: Lỗi xác thực OTP: $e');
      throw Exception('Lỗi khi xác thực mã OTP: $e');
    }
  }

  // Cập nhật mật khẩu mới
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
