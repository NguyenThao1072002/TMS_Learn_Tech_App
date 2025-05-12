import 'package:tms_app/domain/repositories/account_repository.dart';

class SendOtpToEmailUseCase {
  final AccountRepository accountRepository;

  SendOtpToEmailUseCase(this.accountRepository);

  Future<bool> call(Map<String, dynamic> body) async {
    try {
      // Đảm bảo có tham số 'identifier'
      if (!body.containsKey('identifier')) {
        print('Thiếu tham số identifier');
        return false;
      }

      return await accountRepository.sendOtpToEmail(body);
    } catch (e) {
      print('Lỗi gửi OTP: $e');
      return false;
    }
  }
}
