import 'package:tms_app/data/models/my_course/test_submission_model.dart';
import 'package:tms_app/domain/repositories/my_course/test_submission_repository.dart';

/// UseCase xử lý việc gửi câu trả lời bài kiểm tra
class TestSubmissionUseCase {
  /// Repository xử lý việc gửi câu trả lời bài kiểm tra
  final TestSubmissionRepository _repository;

  /// Constructor
  TestSubmissionUseCase(this._repository);

  /// Gửi câu trả lời bài kiểm tra thông thường
  ///
  /// [request] Dữ liệu yêu cầu gửi bài kiểm tra
  Future<TestSubmissionResponse> submitLessonTest(
      TestSubmissionRequest request) async {
    final response = await _repository.submitTestAnswers(request);
    return response as TestSubmissionResponse;
  }

  /// Gửi câu trả lời bài kiểm tra chương
  ///
  /// [request] Dữ liệu yêu cầu gửi bài kiểm tra
  Future<ChapterTestSubmissionResponse> submitChapterTest(
      TestSubmissionRequest request) async {
    final response = await _repository.submitTestAnswers(request);
    return response as ChapterTestSubmissionResponse;
  }
}
