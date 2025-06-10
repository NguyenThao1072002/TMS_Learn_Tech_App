/// Model đại diện cho phản hồi API từ lấy danh sách kết quả làm bài của bài kiểm tra
class TestResultDetailResponse {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Danh sách kết quả làm bài
  final List<TestResultDetail> data;

  TestResultDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo TestResultDetailResponse từ JSON
  factory TestResultDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    
    return TestResultDetailResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: dataList.map((item) => TestResultDetail.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  /// Chuyển đổi TestResultDetailResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model đại diện cho một kết quả làm bài cụ thể
class TestResultDetail {
  /// ID của kết quả làm bài
  final int id;
  
  /// Thời gian hoàn thành bài thi
  final DateTime completedAt;
  
  /// Số câu trả lời đúng
  final int correctAnswers;
  
  /// Số câu trả lời sai
  final int incorrectAnswers;
  
  /// Kết quả (Pass/Fail)
  final String result;
  
  /// Điểm số đạt được
  final double score;
  
  /// Tổng số câu hỏi
  final int totalQuestions;
  
  /// ID của tài khoản làm bài
  final int accountId;
  
  /// ID của bài kiểm tra
  final int testId;
  
  /// ID của khóa học (nếu có)
  final int? courseId;
  
  /// Ngày xóa (nếu có)
  final DateTime? deletedDate;
  
  /// Đã xóa hay chưa
  final bool deleted;
  
  /// Có phải là bài kiểm tra chương không
  final bool isChapterTest;
  
  /// Tiêu đề bài kiểm tra
  final String testTitle;

  TestResultDetail({
    required this.id,
    required this.completedAt,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.result,
    required this.score,
    required this.totalQuestions,
    required this.accountId,
    required this.testId,
    this.courseId,
    this.deletedDate,
    required this.deleted,
    required this.isChapterTest,
    required this.testTitle,
  });

  /// Factory constructor để tạo TestResultDetail từ JSON
  factory TestResultDetail.fromJson(Map<String, dynamic> json) {
    return TestResultDetail(
      id: json['id'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      result: json['result'] as String,
      score: (json['score'] as num).toDouble(),
      totalQuestions: json['totalQuestions'] as int,
      accountId: json['accountId'] as int,
      testId: json['testId'] as int,
      courseId: json['courseId'] as int?,
      deletedDate: json['deletedDate'] != null ? DateTime.parse(json['deletedDate'] as String) : null,
      deleted: json['deleted'] as bool,
      isChapterTest: json['isChapterTest'] as bool,
      testTitle: json['testTitle'] as String,
    );
  }

  /// Chuyển đổi TestResultDetail thành Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'result': result,
      'score': score,
      'totalQuestions': totalQuestions,
      'accountId': accountId,
      'testId': testId,
      'courseId': courseId,
      'deletedDate': deletedDate?.toIso8601String(),
      'deleted': deleted,
      'isChapterTest': isChapterTest,
      'testTitle': testTitle,
    };
  }
  
  /// Tính tỷ lệ câu trả lời đúng (phần trăm)
  double get correctPercentage => (correctAnswers / totalQuestions) * 100;
  
  /// Tính tỷ lệ hoàn thành (phần trăm)
  double get completionPercentage => ((correctAnswers + incorrectAnswers) / totalQuestions) * 100;
} 