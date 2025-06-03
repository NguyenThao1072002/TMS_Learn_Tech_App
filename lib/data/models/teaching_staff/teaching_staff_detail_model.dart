/// Model chi tiết thông tin giảng viên
class TeachingStaffDetailResponse {
  final int status;
  final String message;
  final TeachingStaffDetail data;

  TeachingStaffDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TeachingStaffDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeachingStaffDetailResponse(
      status: json['status'] ?? 200,
      message: json['message'] ?? 'Lấy chi tiết giảng viên thành công',
      data: TeachingStaffDetail.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Model chi tiết thông tin giảng viên
class TeachingStaffDetail {
  /// ID của giảng viên
  final int id;

  /// ID tài khoản của giảng viên
  final int accountId;

  /// Họ tên đầy đủ của giảng viên
  final String fullname;

  /// URL ảnh đại diện
  final String avatarUrl;

  /// Số lượng khóa học của giảng viên
  final int courseCount;

  /// Điểm đánh giá trung bình
  final double averageRating;

  /// Phương pháp giảng dạy
  final String instruction;

  /// Chuyên môn của giảng viên
  final String expert;

  /// Tổng số học viên đã dạy
  final int totalStudents;

  /// ID danh mục giảng dạy
  final int categoryId;

  /// Tên danh mục giảng dạy
  final String categoryName;

  /// Constructor
  TeachingStaffDetail({
    required this.id,
    required this.accountId,
    required this.fullname,
    required this.avatarUrl,
    required this.courseCount,
    required this.averageRating,
    required this.instruction,
    required this.expert,
    required this.totalStudents,
    required this.categoryId,
    required this.categoryName,
  });

  /// Chuyển đổi từ JSON sang object
  factory TeachingStaffDetail.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý URL ảnh
      String avatarUrl = json['avatarUrl'] ?? '';
      if (avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http') &&
          !avatarUrl.startsWith('assets/')) {
        avatarUrl = 'http://103.166.143.198:8080' +
            (avatarUrl.startsWith('/') ? '' : '/') +
            avatarUrl;
      }

      // Xử lý averageRating
      final rating = json['averageRating'] ?? 0.0;
      final averageRating = rating is double ? rating : rating.toDouble();

      return TeachingStaffDetail(
        id: json['id'] ?? 0,
        accountId: json['accountId'] ?? 0,
        fullname: json['fullname'] ?? '',
        avatarUrl: avatarUrl,
        courseCount: json['courseCount'] ?? 0,
        averageRating: averageRating,
        instruction: json['instruction'] ?? '',
        expert: json['expert'] ?? '',
        totalStudents: json['totalStudents'] ?? 0,
        categoryId: json['categoryId'] ?? 0,
        categoryName: json['categoryName'] ?? '',
      );
    } catch (e) {
      // Trả về đối tượng mặc định an toàn khi có lỗi
      return TeachingStaffDetail(
        id: 0,
        accountId: 0,
        fullname: 'Lỗi tải thông tin chi tiết giảng viên',
        avatarUrl: '',
        courseCount: 0,
        averageRating: 0.0,
        instruction: '',
        expert: '',
        totalStudents: 0,
        categoryId: 0,
        categoryName: '',
      );
    }
  }

  /// Chuyển đổi từ object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'fullname': fullname,
      'avatarUrl': avatarUrl,
      'courseCount': courseCount,
      'averageRating': averageRating,
      'instruction': instruction,
      'expert': expert,
      'totalStudents': totalStudents,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
