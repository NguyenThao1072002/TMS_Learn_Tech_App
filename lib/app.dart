import 'package:dio/dio.dart';
import 'package:tms_app/data/services/auth_service.dart';
import 'package:tms_app/data/services/user_service.dart';
import 'package:tms_app/data/repositories/account_repository_impl.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class App {
  // Hàm khởi tạo các dịch vụ và repository
  static AccountRepository initialize() {
    final dio = Dio(); // Khởi tạo Dio client
    
    // Khởi tạo các service
    final authService = AuthService(dio);
    final userService = UserService(dio);

    // Tạo và trả về AccountRepository với các service đã được khởi tạo
    return AccountRepositoryImpl(
        authService: authService, userService: userService);
  }
}
