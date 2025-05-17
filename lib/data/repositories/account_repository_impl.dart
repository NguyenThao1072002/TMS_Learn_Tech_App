import 'package:tms_app/data/models/account/user_update_model.dart';
import 'package:tms_app/data/models/account/overview_my_account_model.dart';

import '../../domain/repositories/account_repository.dart';
import '../models/account/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AuthService authService;
  final UserService userService;

  // Khởi tạo repository với các dịch vụ
  AccountRepositoryImpl({required this.authService, required this.userService});

  // Thực hiện đăng nhập thông qua AuthService
  @override
  Future<Map<String, dynamic>?> login(Map<String, dynamic> body) {
    return authService.login(body);
  }

  // Đăng ký tài khoản mới
  @override
  Future<Map<String, dynamic>?> register(Map<String, dynamic> body) {
    return authService.register(body);
  }

  // Lấy thông tin người dùng từ bộ nhớ cục bộ
  @override
  Future<Map<String, String?>> getUserData() {
    return authService.getUserData();
  }

  // Lấy danh sách tất cả người dùng
  @override
  Future<List<UserDto>> getUsers() {
    return userService.getUsers();
  }

  // Gửi OTP xác thực qua email
  @override
  Future<bool> sendOtpToEmail(Map<String, dynamic> body) {
    return authService.sendOtpToEmail(body);
  }

  // Cập nhật mật khẩu (quên mật khẩu)
  @override
  Future<bool> updatePassword(Map<String, dynamic> body) {
    return authService.updatePassword(body);
  }

  // Xác thực mã OTP
  @override
  Future<bool> verifyOtp(Map<String, dynamic> body) {
    return authService.verifyOtp(body);
  }

  // Cập nhật thông tin tài khoản
  @override
  Future<bool> updateAccount(Map<String, dynamic> body) {
    return userService.updateAccount(body);
  }

  // Lấy thông tin người dùng theo ID
  @override
  Future<UserProfile> getUserById(String userId) {
    return userService.getUserById(userId);
  }

  // Đổi mật khẩu (yêu cầu xác thực)
  @override
  Future<bool> changePassword(Map<String, dynamic> body) {
    return authService.changePassword(body);
  }

  // Đăng nhập bằng Google
  @override
  Future<Map<String, dynamic>?> loginWithGoogle(Map<String, dynamic> body) {
    return authService.loginWithGoogle(body);
  }

  // Lấy tổng quan tài khoản người dùng
  @override
  Future<AccountOverviewModel> getAccountOverview(String userId) {
    return userService.getAccountOverview(userId);
  }

  // Gửi yêu cầu quên mật khẩu
  @override
  Future<bool> forgotPassword(String email) {
    return authService.forgotPassword(email);
  }
}
