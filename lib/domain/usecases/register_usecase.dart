import 'package:tms_app/domain/repositories/account_repository.dart';

class RegisterUseCase {
  final AccountRepository accountRepository;

  RegisterUseCase({required this.accountRepository});

  Future<Map<String, dynamic>?> call(
    String name,
    String email,
    String birthday,
    String phone,
    String password,
  ) async {
    final body = {
      'name': name,
      'email': email,
      'birthday': birthday,
      'phone': phone,
      'password': password,
    };

    // Gọi repository để thực hiện đăng ký
    return await accountRepository.register(body);
  }
}
