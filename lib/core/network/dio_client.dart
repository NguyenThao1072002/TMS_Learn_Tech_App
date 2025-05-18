import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../utils/constants.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/auth/auth_manager.dart';

/// Lớp DioClient bọc Dio để quản lý việc kiểm tra token trước mỗi request
class DioClient {
  final Dio _dio;
  final AuthService _authService;
  AuthManager? _authManager;

  DioClient(this._dio, this._authService);

  /// Factory để lấy DioClient từ GetIt
  static DioClient get instance {
    final dio = GetIt.instance<Dio>();
    final authService = GetIt.instance<AuthService>();
    return DioClient(dio, authService);
  }

  /// Phương thức để lấy AuthManager một cách lazy
  AuthManager get authManager {
    _authManager ??= GetIt.instance<AuthManager>();
    return _authManager!;
  }

  /// Phương thức GET có kiểm tra token
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // Nếu yêu cầu xác thực, kiểm tra và làm mới token nếu cần
    if (requiresAuth) {
      final tokenValid = await _checkAndRefreshToken();
      if (!tokenValid) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Token không hợp lệ hoặc đã hết hạn',
          type: DioExceptionType.unknown,
        );
      }
    }

    // Thêm token vào header nếu cần
    options = await _addAuthHeader(options, requiresAuth);

    try {
      // Thực hiện request
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Phương thức POST có kiểm tra token
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // Nếu yêu cầu xác thực, kiểm tra và làm mới token nếu cần
    if (requiresAuth) {
      final tokenValid = await _checkAndRefreshToken();
      if (!tokenValid) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Token không hợp lệ hoặc đã hết hạn',
          type: DioExceptionType.unknown,
        );
      }
    }

    // Thêm token vào header nếu cần
    options = await _addAuthHeader(options, requiresAuth);

    try {
      // Thực hiện request
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Phương thức PUT có kiểm tra token
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // Nếu yêu cầu xác thực, kiểm tra và làm mới token nếu cần
    if (requiresAuth) {
      final tokenValid = await _checkAndRefreshToken();
      if (!tokenValid) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Token không hợp lệ hoặc đã hết hạn',
          type: DioExceptionType.unknown,
        );
      }
    }

    // Thêm token vào header nếu cần
    options = await _addAuthHeader(options, requiresAuth);

    try {
      // Thực hiện request
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Phương thức DELETE có kiểm tra token
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    // Nếu yêu cầu xác thực, kiểm tra và làm mới token nếu cần
    if (requiresAuth) {
      final tokenValid = await _checkAndRefreshToken();
      if (!tokenValid) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Token không hợp lệ hoặc đã hết hạn',
          type: DioExceptionType.unknown,
        );
      }
    }

    // Thêm token vào header nếu cần
    options = await _addAuthHeader(options, requiresAuth);

    try {
      // Thực hiện request
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Phương thức PATCH có kiểm tra token
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // Nếu yêu cầu xác thực, kiểm tra và làm mới token nếu cần
    if (requiresAuth) {
      final tokenValid = await _checkAndRefreshToken();
      if (!tokenValid) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Token không hợp lệ hoặc đã hết hạn',
          type: DioExceptionType.unknown,
        );
      }
    }

    // Thêm token vào header nếu cần
    options = await _addAuthHeader(options, requiresAuth);

    try {
      // Thực hiện request
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Kiểm tra và làm mới token nếu cần, trả về true nếu token hợp lệ hoặc đã làm mới thành công
  Future<bool> _checkAndRefreshToken() async {
    final token = await SharedPrefs.getJwtToken();

    // Nếu không có token, không cần làm gì
    if (token == null || token.isEmpty) {
      print('Không có token để kiểm tra');
      // Điều hướng đến trang đăng nhập
      _redirectToLogin();
      return false;
    }

    // Kiểm tra xem token có hết hạn không
    if (_authService.isTokenExpired(token)) {
      print('Token đã hết hạn, đang làm mới...');
      final refreshed = await _authService.refreshToken();
      if (!refreshed) {
        print('Không thể làm mới token, chuyển về màn hình đăng nhập');
        // Điều hướng đến trang đăng nhập
        _redirectToLogin();
        return false;
      } else {
        print('Đã làm mới token thành công');
        return true;
      }
    } else {
      print('Token vẫn còn hiệu lực');
      return true;
    }
  }

  /// Thêm token vào header
  Future<Options> _addAuthHeader(Options? options, bool requiresAuth) async {
    options = options ?? Options();

    if (requiresAuth) {
      final token = await SharedPrefs.getJwtToken();
      if (token != null && token.isNotEmpty) {
        options.headers = options.headers ?? {};
        options.headers!['Authorization'] = 'Bearer $token';
      }
    }

    return options;
  }

  /// Xử lý lỗi Dio và chuyển về trang đăng nhập nếu gặp lỗi xác thực
  Future<Response<T>> _handleDioError<T>(DioException error) async {
    print('Lỗi khi gọi API: ${error.message}');

    // Nếu là lỗi 401 Unauthorized
    if (error.response?.statusCode == 401) {
      print('Lỗi xác thực (401), chuyển về màn hình đăng nhập');
      // Thử làm mới token
      final refreshed = await _authService.refreshToken();
      if (!refreshed) {
        // Nếu làm mới token thất bại, chuyển về trang đăng nhập
        _redirectToLogin();
      } else {
        // Nếu làm mới token thành công, thử lại request
        try {
          final requestOptions = error.requestOptions;
          // Lấy token mới
          final newToken = await SharedPrefs.getJwtToken();
          // Cập nhật header
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          // Thực hiện lại request
          final response = await _dio.fetch<T>(requestOptions);
          return response;
        } catch (e) {
          // Nếu vẫn lỗi, chuyển về trang đăng nhập
          _redirectToLogin();
        }
      }
    } else if (error.response?.statusCode == 403) {
      // Lỗi Forbidden cũng có thể là do vấn đề về quyền
      print('Lỗi quyền truy cập (403), chuyển về màn hình đăng nhập');
      _redirectToLogin();
    }

    // Ném lại lỗi để caller xử lý
    throw error;
  }

  /// Chuyển hướng người dùng đến trang đăng nhập
  void _redirectToLogin() {
    // Sử dụng AuthManager để đăng xuất và điều hướng
    authManager.logout(showMessage: true);
  }
}
