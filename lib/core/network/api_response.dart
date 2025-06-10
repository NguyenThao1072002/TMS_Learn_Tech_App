/// Lớp ApiResponse đại diện cho phản hồi từ API
class ApiResponse<T> {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Dữ liệu trả về từ API
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo ApiResponse từ JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
    );
  }

  /// Chuyển đổi ApiResponse thành Map
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T data) toJsonT) {
    return {
      'status': status,
      'message': message,
      'data': toJsonT(data),
    };
  }
} 