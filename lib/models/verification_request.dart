class VerificationRequest {
  final int id;
  final DateTime birthday;
  final String email;
  final DateTime expiresAt;
  final String fullname;
  final String otpCode;
  final String password;
  final String phone;

  VerificationRequest({
    required this.id,
    required this.birthday,
    required this.email,
    required this.expiresAt,
    required this.fullname,
    required this.otpCode,
    required this.password,
    required this.phone,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      id: json['id'],
      birthday: DateTime.parse(json['birthday']),
      email: json['email'],
      expiresAt: DateTime.parse(json['expires_at']),
      fullname: json['fullname'],
      otpCode: json['otp_code'],
      password: json['password'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'birthday': birthday.toIso8601String(),
      'email': email,
      'expires_at': expiresAt.toIso8601String(),
      'fullname': fullname,
      'otp_code': otpCode,
      'password': password,
      'phone': phone,
    };
  }
}