import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/data/models/my_course/completed_lession_model.dart';
import 'package:tms_app/data/services/my_course/course_progress_service.dart';
import 'package:tms_app/domain/repositories/my_course/course_progress_repository.dart';

/// Implementation của CourseProgressRepository
class CourseProgressRepositoryImpl implements CourseProgressRepository {
  final CourseProgressService _courseProgressService;

  /// Constructor
  CourseProgressRepositoryImpl(
      {required CourseProgressService courseProgressService})
      : _courseProgressService = courseProgressService;

  @override
  Future<CourseProgressResponse> addCourseProgress(
      int accountId, int courseId) async {
    try {
      return await _courseProgressService.addCourseProgress(
          accountId.toString(), courseId);
    } catch (e) {
      throw Exception('Không thể thêm tiến trình khóa học: $e');
    }
  }

  @override
  Future<UnlockNextLessonResponse> unlockNextLesson(
      String accountId, int courseId, int chapterId, int lessonId) async {
    try {
      return await _courseProgressService.unlockNextLesson(
          accountId, courseId, chapterId, lessonId);
    } catch (e) {
      throw Exception('Không thể mở khóa bài học tiếp theo: $e');
    }
  }

  // @override
  // Future<CourseProgressResponse> updateCourseProgress(
  //     CourseProgressModel progressModel) async {
  //   try {
  //     return await _courseProgressService.updateCourseProgress(progressModel);
  //   } catch (e) {
  //     throw Exception('Không thể cập nhật tiến trình khóa học: $e');
  //   }
  // }

  // @override
  // Future<CourseProgressModel> getCourseProgress(
  //     int accountId, int courseId) async {
  //   try {
  //     return await _courseProgressService.getCourseProgress(
  //         accountId, courseId);
  //   } catch (e) {
  //     throw Exception('Không thể lấy tiến trình khóa học: $e');
  //   }
  // }
}
