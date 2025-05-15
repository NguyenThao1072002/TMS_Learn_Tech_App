import '../repositories/account_repository.dart';

class LoginUseCase {
  final AccountRepository repository;

  // Constructor nhận tham số repository (được inject từ Service Locator)
  LoginUseCase(this.repository);

  // Phương thức call nhận email và password, và gọi phương thức login từ repository
  Future<Map<String, dynamic>?> call(String email, String password) async {
    final body = {
      'email': email,
      'password': password
    }; // Chúng ta có thể tạo một Map ở đây
    return await repository.login(body);
  }

  // Phương thức xử lý đăng nhập với Google
  Future<Map<String, dynamic>?> callGoogleLogin(
      Map<String, dynamic> googleData) async {
    return await repository.loginWithGoogle(googleData);
  }
}
