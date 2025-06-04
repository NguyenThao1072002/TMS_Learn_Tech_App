import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/data/models/my_course/completed_lession_model.dart';

/// Interface định nghĩa các phương thức cho repository xử lý tiến trình khóa học
abstract class CourseProgressRepository {
  /// Thêm tiến trình mới khi người dùng bắt đầu học khóa học
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  ///
  /// Trả về [CourseProgressResponse] chứa thông tin tiến trình đã tạo
  Future<CourseProgressResponse> addCourseProgress(int accountId, int courseId);

  /// Mở khóa bài học tiếp theo khi người dùng hoàn thành bài học hiện tại
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  /// [chapterId] ID của chương học
  /// [lessonId] ID của bài học hiện tại
  ///
  /// Trả về [UnlockNextLessonResponse] chứa thông tin tiến trình mới
  Future<UnlockNextLessonResponse> unlockNextLesson(
      String accountId, int courseId, int chapterId, int lessonId);

  // /// Cập nhật tiến trình học tập của người dùng
  // ///
  // /// [progressModel] Model chứa thông tin tiến trình cần cập nhật
  // ///
  // /// Trả về [CourseProgressResponse] chứa thông tin tiến trình đã cập nhật
  // Future<CourseProgressResponse> updateCourseProgress(
  //     CourseProgressModel progressModel);

  // /// Lấy tiến trình học tập của người dùng cho một khóa học cụ thể
  // ///
  // /// [accountId] ID của tài khoản người dùng
  // /// [courseId] ID của khóa học
  // ///
  // /// Trả về [CourseProgressModel] chứa thông tin tiến trình
  // Future<CourseProgressModel> getCourseProgress(int accountId, int courseId);
}
