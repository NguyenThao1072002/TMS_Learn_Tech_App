import 'package:tms_app/domain/repositories/account_repository.dart';

class SendOtpToEmailUseCase {
  final AccountRepository accountRepository;

  SendOtpToEmailUseCase(this.accountRepository);

  Future<bool> call(Map<String, dynamic> body) async {
    return await accountRepository
        .sendOtpToEmail(body); // Gọi phương thức từ AccountRepository
  }
}
