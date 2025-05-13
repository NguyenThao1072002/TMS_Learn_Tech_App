import 'package:tms_app/data/models/user_update_model.dart';

import '../../domain/repositories/account_repository.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AuthService authService;
  final UserService userService;

  // Khởi tạo repository với các dịch vụ
  AccountRepositoryImpl({required this.authService, required this.userService});

  @override
  Future<Map<String, dynamic>?> login(Map<String, dynamic> body) {
    return authService.login(body);
  }

  @override
  Future<Map<String, dynamic>?> register(Map<String, dynamic> body) {
    return authService.register(body);
  }

  @override
  Future<Map<String, String?>> getUserData() {
    return authService.getUserData();
  }

  @override
  Future<List<UserDto>> getUsers() {
    return userService.getUsers();
  }

  @override
  Future<bool> sendOtpToEmail(Map<String, dynamic> body) {
    return authService.sendOtpToEmail(body);
  }

  // @override
  // Future<bool> sendOtpToPhone(Map<String, dynamic> body) {
  //   return authService
  //       .sendOtpToPhone(body);
  // }

  @override
  Future<bool> updatePassword(Map<String, dynamic> body) {
    return authService.updatePassword(body);
  }

  @override
  Future<bool> verifyOtp(Map<String, dynamic> body) {
    return authService.verifyOtp(body);
  }

  @override
  Future<bool> updateAccount(Map<String, dynamic> body) {
    return userService.updateAccount(body);
  }

  @override
  Future<UserProfile> getUserById(String userId) {
    return userService.getUserById(userId);
  }
}
