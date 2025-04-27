import 'package:tms_app/domain/repositories/account_repository.dart';

class ForgotPasswordUseCase {
  final AccountRepository accountRepository;

  ForgotPasswordUseCase(this.accountRepository);

  // Thay đổi kiểu trả về thành Map<String, String?> và xử lý lỗi
  Future<Map<String, String?>> call() async {
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
}
