import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/data/models/my_course/completed_lession_model.dart';
import 'package:tms_app/domain/repositories/my_course/course_progress_repository.dart';

/// UseCase xử lý thêm tiến trình khóa học khi người dùng bắt đầu học lần đầu
class AddCourseProgressUseCase {
  final CourseProgressRepository _repository;

  /// Constructor
  AddCourseProgressUseCase(this._repository);

  /// Thêm tiến trình mới khi người dùng bắt đầu học khóa học
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  ///
  /// Trả về [CourseProgressResponse] chứa thông tin tiến trình đã tạo
  Future<CourseProgressResponse> execute(int accountId, int courseId) async {
    try {
      return await _repository.addCourseProgress(accountId, courseId);
    } catch (e) {
      throw Exception('Không thể khởi tạo tiến trình học tập: $e');
    }
  }
}

/// UseCase xử lý mở khóa bài học tiếp theo khi người dùng hoàn thành bài học hiện tại
class UnlockNextLessonUseCase {
  final CourseProgressRepository _repository;

  /// Constructor
  UnlockNextLessonUseCase(this._repository);

  /// Mở khóa bài học tiếp theo khi người dùng hoàn thành bài học hiện tại
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  /// [chapterId] ID của chương học
  /// [lessonId] ID của bài học hiện tại
  ///
  /// Trả về [UnlockNextLessonResponse] chứa thông tin tiến trình mới
  Future<UnlockNextLessonResponse> execute(
      String accountId, int courseId, int chapterId, int lessonId) async {
    try {
      return await _repository.unlockNextLesson(
          accountId, courseId, chapterId, lessonId);
    } catch (e) {
      throw Exception('Không thể mở khóa bài học tiếp theo: $e');
    }
  }
}
