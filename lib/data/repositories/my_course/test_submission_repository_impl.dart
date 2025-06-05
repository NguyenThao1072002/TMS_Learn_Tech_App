import 'package:tms_app/data/models/my_course/test_submission_model.dart';
import 'package:tms_app/data/services/my_course/course_progress_service.dart';
import 'package:tms_app/domain/repositories/my_course/test_submission_repository.dart';

/// Implementation của TestSubmissionRepository
class TestSubmissionRepositoryImpl implements TestSubmissionRepository {
  /// Service xử lý API liên quan đến tiến trình học tập
  final CourseProgressService _courseProgressService;

  /// Constructor
  TestSubmissionRepositoryImpl(this._courseProgressService);

  @override
  Future<dynamic> submitTestAnswers(TestSubmissionRequest request) async {
    return await _courseProgressService.submitTestAnswers(request);
  }
}
