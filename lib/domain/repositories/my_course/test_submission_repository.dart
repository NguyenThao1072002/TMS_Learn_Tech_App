import 'package:tms_app/data/models/my_course/test_submission_model.dart';

/// Repository xử lý việc gửi câu trả lời bài kiểm tra
abstract class TestSubmissionRepository {
  /// Gửi câu trả lời bài kiểm tra
  ///
  /// [request] Dữ liệu yêu cầu gửi bài kiểm tra
  Future<dynamic> submitTestAnswers(TestSubmissionRequest request);
}
