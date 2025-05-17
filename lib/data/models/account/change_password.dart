// Mô hình dữ liệu cho yêu cầu đổi mật khẩu
class ChangePasswordModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  // Chuyển đổi thành định dạng JSON để gửi đến API
  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
