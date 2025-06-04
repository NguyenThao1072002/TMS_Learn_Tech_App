/// Model đại diện cho tiến trình học tập của người dùng với một khóa học cụ thể
class CourseProgressModel {
  /// ID của tiến trình
  final int id;

  /// Trạng thái hoàn thành video
  final bool videoCompleted;

  /// Trạng thái hoàn thành bài kiểm tra
  final bool testCompleted;

  /// Trạng thái kiểm tra chương
  final bool chapterTested;

  /// Điểm số bài kiểm tra
  final int? testScore;

  /// Thời gian hoàn thành
  final DateTime completedAt;

  /// ID của tài khoản người dùng
  final int accountId;

  /// ID của khóa học
  final int courseId;

  /// ID của chương học
  final int chapterId;

  /// ID của bài học
  final int lessonId;

  /// Constructor
  CourseProgressModel({
    required this.id,
    required this.videoCompleted,
    required this.testCompleted,
    required this.chapterTested,
    this.testScore,
    required this.completedAt,
    required this.accountId,
    required this.courseId,
    required this.chapterId,
    required this.lessonId,
  });

  /// Factory tạo đối tượng từ JSON
  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      id: json['id'] ?? 0,
      videoCompleted: json['videoCompleted'] ?? false,
      testCompleted: json['testCompleted'] ?? false,
      chapterTested: json['chapterTested'] ?? false,
      testScore: json['testScore'],
      completedAt:
          DateTime.parse(json['completedAt'] ?? DateTime.now().toString()),
      accountId: json['accountId'] ?? 0,
      courseId: json['courseId'] ?? 0,
      chapterId: json['chapterId'] ?? 0,
      lessonId: json['lessonId'] ?? 0,
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoCompleted': videoCompleted,
      'testCompleted': testCompleted,
      'chapterTested': chapterTested,
      'testScore': testScore,
      'completedAt': completedAt.toIso8601String(),
      'accountId': accountId,
      'courseId': courseId,
      'chapterId': chapterId,
      'lessonId': lessonId,
    };
  }

  /// Tạo bản sao với một số thuộc tính được thay đổi
  CourseProgressModel copyWith({
    int? id,
    bool? videoCompleted,
    bool? testCompleted,
    bool? chapterTested,
    int? testScore,
    DateTime? completedAt,
    int? accountId,
    int? courseId,
    int? chapterId,
    int? lessonId,
  }) {
    return CourseProgressModel(
      id: id ?? this.id,
      videoCompleted: videoCompleted ?? this.videoCompleted,
      testCompleted: testCompleted ?? this.testCompleted,
      chapterTested: chapterTested ?? this.chapterTested,
      testScore: testScore ?? this.testScore,
      completedAt: completedAt ?? this.completedAt,
      accountId: accountId ?? this.accountId,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      lessonId: lessonId ?? this.lessonId,
    );
  }
}

/// Model đại diện cho response khi tạo tiến trình học tập mới
class CourseProgressResponse {
  /// Mã trạng thái
  final int status;

  /// Thông báo
  final String message;

  /// Dữ liệu tiến trình học tập
  final CourseProgressModel data;

  /// Constructor
  CourseProgressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory tạo đối tượng từ JSON
  factory CourseProgressResponse.fromJson(Map<String, dynamic> json) {
    return CourseProgressResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: CourseProgressModel.fromJson(json['data'] ?? {}),
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
