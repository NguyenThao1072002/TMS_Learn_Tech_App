import 'package:tms_app/data/models/course_progress_model.dart';

/// Model đại diện cho response khi hoàn thành bài học và mở khóa bài học tiếp theo
class UnlockNextLessonResponse {
  /// Mã trạng thái
  final int status;

  /// Thông báo
  final String message;

  /// Dữ liệu phản hồi
  final UnlockNextLessonData data;

  /// Constructor
  UnlockNextLessonResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory tạo đối tượng từ JSON
  factory UnlockNextLessonResponse.fromJson(Map<String, dynamic> json) {
    return UnlockNextLessonResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: UnlockNextLessonData.fromJson(json['data'] ?? {}),
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

/// Model đại diện cho dữ liệu phản hồi khi mở khóa bài học tiếp theo
class UnlockNextLessonData {
  /// Thông tin tiến trình học tập
  final CourseProgressModel progress;

  /// Thông báo
  final String message;

  /// Constructor
  UnlockNextLessonData({
    required this.progress,
    required this.message,
  });

  /// Factory tạo đối tượng từ JSON
  factory UnlockNextLessonData.fromJson(Map<String, dynamic> json) {
    return UnlockNextLessonData(
      progress: CourseProgressModel.fromJson(json['progress'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'progress': progress.toJson(),
      'message': message,
    };
  }
}
