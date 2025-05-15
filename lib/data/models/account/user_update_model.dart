class UserProfile {
  String? fullname;
  String? email;
  String? phone;
  String? gender;
  String? birthday;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? roleId;

  UserProfile({
    this.fullname,
    this.email,
    this.phone,
    this.gender,
    this.birthday,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.roleId,
  });

  // Factory method để tạo từ Map (JSON)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Nếu map có cấu trúc API response
    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    return UserProfile(
      fullname: map['fullname'],
      email: map['email'],
      phone: map['phone'],
      gender: map['gender'], // Mặc định là Nam nếu không có
      birthday: map['birthday'],
      image: map['image'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      roleId: map['roleId'],
    );
  }

  // Chuyển đổi từ model sang Map để gửi lên API
  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'image': image,
      'roleId': roleId,
    };
  }
}
