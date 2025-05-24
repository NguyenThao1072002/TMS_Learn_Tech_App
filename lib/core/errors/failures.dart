import 'package:equatable/equatable.dart';

/// Lớp cơ sở cho các lỗi trong ứng dụng
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Lỗi từ server
class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure({required String message, required this.statusCode})
      : super(message: message);

  @override
  List<Object> get props => [message, statusCode];
}

/// Lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Không có kết nối mạng'})
      : super(message: message);
}

/// Lỗi xác thực
class AuthFailure extends Failure {
  const AuthFailure({String message = 'Lỗi xác thực'})
      : super(message: message);
}

/// Lỗi cache
class CacheFailure extends Failure {
  const CacheFailure({String message = 'Lỗi cache'}) : super(message: message);
}

/// Lỗi định dạng dữ liệu
class FormatFailure extends Failure {
  const FormatFailure({String message = 'Lỗi định dạng dữ liệu'})
      : super(message: message);
}
