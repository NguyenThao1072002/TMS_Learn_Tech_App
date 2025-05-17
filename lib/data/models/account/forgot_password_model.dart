// Mô hình dữ liệu cho yêu cầu đặt lại mật khẩu
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  // Chuyển đổi thành định dạng JSON để gửi đến API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Mô hình dữ liệu cho phản hồi từ API đặt lại mật khẩu
class ForgotPasswordResponse {
  final int status;
  final String message;
  final String data;

  ForgotPasswordResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  // Tạo đối tượng từ JSON nhận được từ API
  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}
