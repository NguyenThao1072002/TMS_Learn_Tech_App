import 'package:tms_app/data/models/account/user_model.dart';
import 'package:tms_app/data/models/account/user_update_model.dart';
import 'package:tms_app/data/models/account/overview_my_account_model.dart';

abstract class AccountRepository {
  // Đăng nhập vào hệ thống
  Future<Map<String, dynamic>?> login(Map<String, dynamic> body);

  // Đăng ký tài khoản mới
  Future<Map<String, dynamic>?> register(Map<String, dynamic> body);

  // Gửi OTP xác thực qua email
  Future<bool> sendOtpToEmail(Map<String, dynamic> body);

  // Lấy thông tin người dùng từ bộ nhớ cục bộ
  Future<Map<String, String?>> getUserData();

  // Lấy danh sách người dùng (dành cho admin)
  Future<List<UserDto>> getUsers();

  // Xác thực mã OTP
  Future<bool> verifyOtp(Map<String, dynamic> body);

  // Cập nhật mật khẩu mới (quên mật khẩu)
  Future<bool> updatePassword(Map<String, dynamic> body);

  // Cập nhật thông tin tài khoản
  Future<bool> updateAccount(Map<String, dynamic> body);

  // Lấy thông tin chi tiết của người dùng theo ID
  Future<UserProfile> getUserById(String userId);

  // Đổi mật khẩu (yêu cầu xác thực)
  Future<bool> changePassword(Map<String, dynamic> body);

  // Đăng nhập bằng Google
  Future<Map<String, dynamic>?> loginWithGoogle(Map<String, dynamic> body);

  // Lấy tổng quan tài khoản người dùng
  Future<AccountOverviewModel> getAccountOverview(String userId);

  // Gửi yêu cầu quên mật khẩu
  Future<bool> forgotPassword(String email);
}
