import 'package:tms_app/domain/repositories/account_repository.dart';
import 'dart:convert';

class SendOtpToEmailUseCase {
  final AccountRepository accountRepository;

  SendOtpToEmailUseCase(this.accountRepository);

  Future<bool> call(Map<String, dynamic> body) async {
    try {
      print('📲 SendOtpToEmailUseCase - Bắt đầu gửi OTP');

      // Đảm bảo có tham số 'identifier'
      if (!body.containsKey('identifier')) {
        print('❌ SendOtpToEmailUseCase - Thiếu tham số identifier');
        return false;
      }

      // Thêm tham số type để phân biệt loại gửi OTP
      Map<String, dynamic> updatedBody = Map.from(body);
      updatedBody['type'] = 'REGISTER';

      print('📲 SendOtpToEmailUseCase - Tham số: ${jsonEncode(updatedBody)}');

      final result = await accountRepository.sendOtpToEmail(updatedBody);
      print('📲 SendOtpToEmailUseCase - Kết quả: $result');

      return result;
    } catch (e) {
      print('❌ SendOtpToEmailUseCase - Lỗi gửi OTP: $e');
      return false;
    }
  }
}
