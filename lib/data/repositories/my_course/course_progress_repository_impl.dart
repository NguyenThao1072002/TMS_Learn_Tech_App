import 'package:tms_app/data/models/course_progress_model.dart';
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
      String accountId, int courseId) async {
    try {
      return await _courseProgressService.addCourseProgress(
          accountId, courseId);
    } catch (e) {
      throw Exception('Không thể thêm tiến trình khóa học: $e');
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
