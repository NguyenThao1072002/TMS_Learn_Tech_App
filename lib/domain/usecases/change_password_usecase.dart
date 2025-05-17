import 'package:tms_app/data/models/account/change_password.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class ChangePasswordUseCase {
  final AccountRepository repository;

  ChangePasswordUseCase(this.repository);

  // Thực hiện đổi mật khẩu cho người dùng đã đăng nhập
  Future<bool> execute(ChangePasswordModel model) async {
    try {
      final result = await repository.changePassword(model.toJson());
      return result;
    } catch (e) {
      return false;
    }
  }
}
