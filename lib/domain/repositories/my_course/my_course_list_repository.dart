import 'package:tms_app/data/models/my_course/my_course_list_model.dart';

abstract class MyCourseListRepository {
  /// Fetches the list of enrolled courses for a user
  ///
  /// [accountId] The ID of the user account
  /// [page] The page number (zero-based)
  /// [size] The number of items per page
  /// [status] The course status filter ("Actived", "Studying", "Completed")
  /// [title] Optional title search parameter
  Future<MyCourseListResponse> getEnrolledCourses({
    required int accountId,
    required int page,
    required int size,
    required String status,
    String? title,
  });
}
