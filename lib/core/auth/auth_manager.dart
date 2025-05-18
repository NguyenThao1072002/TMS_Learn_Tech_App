import 'package:flutter/material.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';

/// Quản lý trạng thái đăng nhập và cung cấp phương thức để đăng xuất toàn cục
class AuthManager {
  // Singleton pattern
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  // Key toàn cục để điều hướng từ bất kỳ đâu trong ứng dụng
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Màn hình đăng nhập route
  final String loginRoute = '/login';

  /// Đăng xuất người dùng và điều hướng về màn hình đăng nhập
  Future<void> logout({bool showMessage = true}) async {
    try {
      // Xóa token và thông tin người dùng
      await SharedPrefs.removeJwtToken();
      final prefs = await SharedPrefs.getSharedPrefs();
      await prefs.remove(SharedPrefs.KEY_REFRESH_TOKEN);
      await prefs.remove(SharedPrefs.KEY_USER_ID);

      // Điều hướng về trang đăng nhập nếu navigatorKey đã được khởi tạo
      if (navigatorKey.currentState != null) {
        // Xóa tất cả các màn hình và chuyển đến màn hình đăng nhập
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );

        // Hiển thị thông báo nếu cần
        if (showMessage) {
          _showLogoutMessage();
        }
      } else {
        print('Không thể điều hướng: navigatorKey chưa được khởi tạo');
      }
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
    }
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await SharedPrefs.getJwtToken();
    return token != null && token.isNotEmpty;
  }

  /// Hiển thị thông báo khi người dùng bị đăng xuất
  void _showLogoutMessage() {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
