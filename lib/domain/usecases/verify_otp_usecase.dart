import 'package:tms_app/data/services/auth_service.dart';

class VerifyOtpUseCase {
  final AuthService authService;

  VerifyOtpUseCase({required this.authService});

  // Xác thực OTP
  Future<bool> execute(String identifier, String otp) async {
    // Tạo Map body với thông tin cần thiết cho API
    Map<String, dynamic> body = {
      'identifier': identifier, // Email hoặc SĐT
      'otp': otp, // Mã OTP
    };

    // Gọi phương thức verifyOtp từ AuthService
    return await authService.verifyOtp(body); // Truyền Map vào API
  }

  // Gửi lại OTP
  Future<bool> resendOtp(String identifier) async {
    // Tạo Map body cho việc gửi lại OTP
    Map<String, dynamic> body = {
      'identifier': identifier, // Email hoặc SĐT
    };

    // Gọi phương thức sendOtp từ AuthService
    return await authService.sendOtp(body); // Gọi phương thức gửi OTP
  }
}
