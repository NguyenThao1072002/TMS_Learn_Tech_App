import 'package:tms_app/data/models/user_model.dart';
import 'package:tms_app/data/services/auth_service.dart';
import 'package:tms_app/data/services/user_service.dart';
import 'package:tms_app/domain/repositories/account_repository.dart'; // Đảm bảo import đúng AccountRepository

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
    return authService
        .sendOtpToEmail(body); 
  }

  // @override
  // Future<bool> sendOtpToPhone(Map<String, dynamic> body) {
  //   return authService
  //       .sendOtpToPhone(body); 
  // }

  @override
  Future<bool> updatePassword(Map<String, dynamic> body) {
    return authService
        .updatePassword(body); 
  }

  @override
  Future<bool> verifyOtp(Map<String, dynamic> body) {
    return authService.verifyOtp(body); 
  }
}
