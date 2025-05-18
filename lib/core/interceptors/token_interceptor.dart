import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/services/auth_service.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import 'package:get_it/get_it.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final AuthService authService;
  bool _isRefreshing = false;
  AuthManager? _authManager;

  TokenInterceptor({required this.dio, required this.authService});

  // Lazily get AuthManager to avoid circular dependency
  AuthManager get authManager {
    _authManager ??= GetIt.instance<AuthManager>();
    return _authManager!;
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Lấy token hiện tại từ SharedPreferences
    final token = await SharedPrefs.getJwtToken();

    // Nếu không có token hoặc yêu cầu không cần token (như đăng nhập, đăng ký)
    if (token == null ||
        options.path.contains('/dang-nhap') ||
        options.path.contains('/register') ||
        options.path.contains('/refresh-token')) {
      return handler.next(options);
    }

    // Kiểm tra xem token đã hết hạn chưa
    if (authService.isTokenExpired(token)) {
      print('Token đã hết hạn, đang làm mới...');
      // Thử làm mới token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Lấy token mới
        final newToken = await SharedPrefs.getJwtToken();
        if (newToken != null) {
          // Cập nhật token trong header
          options.headers['Authorization'] = 'Bearer $newToken';
          return handler.next(options);
        }
      }

      // Nếu không thể làm mới token, chuyển người dùng đến màn hình đăng nhập
      print('Không thể làm mới token, yêu cầu đăng nhập lại');
      _redirectToLogin();
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Token hết hạn hoặc không hợp lệ',
        ),
      );
    }

    // Thêm token vào header
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Kiểm tra nếu lỗi là do token hết hạn (401)
    if (err.response?.statusCode == 401) {
      print('Lỗi 401: Token không hợp lệ hoặc đã hết hạn');

      // Thử làm mới token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Lấy token mới và thử lại yêu cầu
        final newToken = await SharedPrefs.getJwtToken();
        if (newToken != null) {
          print('Đã làm mới token, thử lại yêu cầu');

          // Tạo yêu cầu mới với token mới
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          try {
            // Thực hiện lại yêu cầu
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(DioException(
              requestOptions: options,
              error: 'Lỗi khi thử lại yêu cầu: $e',
            ));
          }
        }
      }

      // Nếu không thể làm mới token, chuyển người dùng đến màn hình đăng nhập
      print('Không thể làm mới token, yêu cầu đăng nhập lại');
      _redirectToLogin();
    }

    // Nếu không phải lỗi 401 hoặc không thể xử lý, trả về lỗi gốc
    return handler.next(err);
  }

  // Hàm để làm mới token, đảm bảo chỉ gọi một lần khi cần
  Future<bool> _refreshToken() async {
    // Kiểm tra nếu đang trong quá trình làm mới token
    if (_isRefreshing) {
      // Đợi cho đến khi quá trình làm mới hoàn tất
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      _isRefreshing = true;
      // Gọi API để làm mới token
      final result = await authService.refreshToken();
      _isRefreshing = false;
      return result;
    } catch (e) {
      _isRefreshing = false;
      print('Lỗi khi làm mới token: $e');
      return false;
    }
  }

  // Chuyển hướng người dùng đến màn hình đăng nhập
  void _redirectToLogin() {
    try {
      // Use AuthManager for redirection
      authManager.logout(showMessage: true);
    } catch (e) {
      print('Lỗi khi chuyển hướng đến màn hình đăng nhập: $e');
      // Fallback: just remove tokens
      SharedPrefs.removeJwtToken();
    }
  }
}
