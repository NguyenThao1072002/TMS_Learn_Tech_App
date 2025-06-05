/// Model đại diện cho câu trả lời của một câu hỏi
class QuestionAnswer {
  /// ID của câu hỏi
  final int questionId;

  /// Kết quả trả lời của học viên
  final String result;

  /// Kết quả kiểm tra (đáp án đã chọn)
  final String resultCheck;

  /// Loại câu hỏi
  final String type;

  /// Constructor
  QuestionAnswer({
    required this.questionId,
    required this.result,
    required this.resultCheck,
    required this.type,
  });

  /// Factory tạo đối tượng từ JSON
  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] ?? 0,
      result: json['result'] ?? '',
      resultCheck: json['resultCheck'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'result': result,
      'resultCheck': resultCheck,
      'type': type,
    };
  }
}

/// Model đại diện cho yêu cầu gửi bài kiểm tra
class TestSubmissionRequest {
  /// ID của bài kiểm tra
  final int testId;

  /// Tổng số câu hỏi
  final int totalQuestion;

  /// Các loại câu hỏi trong bài kiểm tra
  final String type;

  /// Thời gian làm bài (giây)
  final int durationTest;

  /// ID của khóa học
  final int courseId;

  /// ID của tài khoản người dùng
  final int accountId;

  /// ID của chương học
  final int chapterId;

  /// Có phải là bài kiểm tra chương không
  final bool isChapterTest;

  /// Danh sách câu trả lời
  final List<QuestionAnswer> questionResponsiveList;

  /// Constructor
  TestSubmissionRequest({
    required this.testId,
    required this.totalQuestion,
    required this.type,
    required this.durationTest,
    required this.courseId,
    required this.accountId,
    required this.chapterId,
    required this.isChapterTest,
    required this.questionResponsiveList,
  });

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'totalQuestion': totalQuestion,
      'type': type,
      'durationTest': durationTest,
      'courseId': courseId,
      'accountId': accountId,
      'chapterId': chapterId,
      'isChapterTest': isChapterTest,
      'questionResponsiveList':
          questionResponsiveList.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model đại diện cho kết quả bài kiểm tra
class TestResult {
  /// ID của bài kiểm tra
  final int testId;

  /// Số câu trả lời đúng
  final int correctQuestion;

  /// Số câu trả lời sai
  final int incorrectQuestion;

  /// Điểm số
  final double score;

  /// Tổng số câu hỏi
  final int totalQuestion;

  /// ID của tài khoản người dùng
  final int accountId;

  /// Kết quả (Pass/Fail)
  final String resultTest;

  /// Tỷ lệ đúng (%)
  final double rateTesting;

  /// Thời gian làm bài (giây)
  final int durationTest;

  /// ID của khóa học
  final int courseId;

  /// Constructor
  TestResult({
    required this.testId,
    required this.correctQuestion,
    required this.incorrectQuestion,
    required this.score,
    required this.totalQuestion,
    required this.accountId,
    required this.resultTest,
    required this.rateTesting,
    required this.durationTest,
    required this.courseId,
  });

  /// Factory tạo đối tượng từ JSON
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testId: json['testId'] ?? 0,
      correctQuestion: json['correctQuestion'] ?? 0,
      incorrectQuestion: json['incorrectQuestion'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      totalQuestion: json['totalQuestion'] ?? 0,
      accountId: json['accountId'] ?? 0,
      resultTest: json['resultTest'] ?? '',
      rateTesting: (json['rateTesting'] ?? 0.0).toDouble(),
      durationTest: json['durationTest'] ?? 0,
      courseId: json['courseId'] ?? 0,
    );
  }
}

/// Model đại diện cho response khi gửi bài kiểm tra thông thường
class TestSubmissionResponse {
  /// Mã trạng thái
  final int status;

  /// Thông báo
  final String message;

  /// Dữ liệu kết quả
  final TestResult? data;

  /// Constructor
  TestSubmissionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  /// Factory tạo đối tượng từ JSON
  factory TestSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return TestSubmissionResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? TestResult.fromJson(json['data']) : null,
    );
  }
}

/// Model đại diện cho response khi gửi bài kiểm tra chương
class ChapterTestSubmissionResponse {
  /// Mã trạng thái
  final int status;

  /// Thông báo
  final String message;

  /// Dữ liệu (null cho bài kiểm tra chương)
  final dynamic data;

  /// Constructor
  ChapterTestSubmissionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  /// Factory tạo đối tượng từ JSON
  factory ChapterTestSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return ChapterTestSubmissionResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
