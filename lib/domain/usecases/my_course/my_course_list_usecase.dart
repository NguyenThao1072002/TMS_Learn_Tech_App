import 'package:tms_app/data/models/my_course/my_course_list_model.dart';
import 'package:tms_app/domain/repositories/my_course/my_course_list_repository.dart';

class MyCourseListUseCase {
  final MyCourseListRepository _repository;

  MyCourseListUseCase(this._repository);

  /// Get all enrolled courses for a user with optional filtering
  ///
  /// [accountId] The user's account ID
  /// [page] The page number (zero-based)
  /// [size] The number of items per page
  /// [status] The course status filter ("Actived", "Studying", "Completed")
  /// [title] Optional search by title
  Future<MyCourseListResponse> getEnrolledCourses({
    required int accountId,
    required int page,
    required int size,
    required String status,
    String? title,
  }) async {
    try {
      return await _repository.getEnrolledCourses(
        accountId: accountId,
        page: page,
        size: size,
        status: status,
        title: title,
      );
    } catch (e) {
      // Here you could add special business logic handling for errors
      // such as returning cached data if network request fails
      print('UseCase error fetching enrolled courses: $e');
      rethrow;
    }
  }

  /// Convenience method to get all active enrolled courses
  Future<MyCourseListResponse> getActiveCourses({
    required int accountId,
    required int page,
    required int size,
    String? title,
  }) async {
    return getEnrolledCourses(
      accountId: accountId,
      page: page,
      size: size,
      status: 'Actived',
      title: title,
    );
  }

  /// Convenience method to get in-progress courses
  Future<MyCourseListResponse> getStudyingCourses({
    required int accountId,
    required int page,
    required int size,
    String? title,
  }) async {
    return getEnrolledCourses(
      accountId: accountId,
      page: page,
      size: size,
      status: 'Studying',
      title: title,
    );
  }

  /// Convenience method to get completed courses
  Future<MyCourseListResponse> getCompletedCourses({
    required int accountId,
    required int page,
    required int size,
    String? title,
  }) async {
    return getEnrolledCourses(
      accountId: accountId,
      page: page,
      size: size,
      status: 'Completed',
      title: title,
    );
  }
}
