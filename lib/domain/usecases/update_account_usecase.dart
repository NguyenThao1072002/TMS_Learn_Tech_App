import 'package:tms_app/data/models/account/user_update_model.dart';

import '../repositories/account_repository.dart';

class UpdateAccountUseCase {
  final AccountRepository repository;

  // Constructor nhận tham số repository (được inject từ Service Locator)
  UpdateAccountUseCase(this.repository);

  // Phương thức call nhận các thông tin cập nhật tài khoản và gọi phương thức updateAccount từ repository
  Future<bool> call(Map<String, dynamic> accountData) async {
    return await repository.updateAccount(accountData);
  }

  // Phương thức để lấy thông tin chi tiết của user theo ID
  Future<UserProfile> getUserById(String userId) async {
    return await repository.getUserById(userId);
  }
}
