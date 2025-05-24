/// Ngoại lệ cơ sở cho ứng dụng
abstract class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

/// Ngoại lệ khi có lỗi từ server
class ServerException extends AppException {
  final int statusCode;

  ServerException({required String message, required this.statusCode})
      : super(message: message);

  @override
  String toString() => 'ServerException: $message (Status code: $statusCode)';
}

/// Ngoại lệ khi không có kết nối mạng
class NetworkException extends AppException {
  NetworkException({String message = 'Không có kết nối mạng'})
      : super(message: message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Ngoại lệ khi có lỗi xác thực
class AuthException extends AppException {
  AuthException({String message = 'Lỗi xác thực'}) : super(message: message);

  @override
  String toString() => 'AuthException: $message';
}

/// Ngoại lệ khi có lỗi cache
class CacheException extends AppException {
  CacheException({String message = 'Lỗi cache'}) : super(message: message);

  @override
  String toString() => 'CacheException: $message';
}

/// Ngoại lệ khi có lỗi định dạng dữ liệu
class FormatException extends AppException {
  FormatException({String message = 'Lỗi định dạng dữ liệu'})
      : super(message: message);

  @override
  String toString() => 'FormatException: $message';
}
