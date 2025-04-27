import 'package:tms_app/data/models/user_model.dart';

abstract class AccountRepository {
  Future<Map<String, dynamic>?> login(Map<String, dynamic> body);
  Future<Map<String, dynamic>?> register(Map<String, dynamic> body);
  Future<bool> sendOtpToEmail(Map<String, dynamic> body);
  Future<Map<String, String?>> getUserData();
  Future<List<UserDto>> getUsers();
  // Future<bool> sendOtpToPhone(Map<String, dynamic> body);
  Future<bool> verifyOtp(Map<String, dynamic> body);
  Future<bool> updatePassword(Map<String, dynamic> body);
}
