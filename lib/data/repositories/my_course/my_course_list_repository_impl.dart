import 'package:tms_app/data/models/my_course/my_course_list_model.dart';
import 'package:tms_app/data/services/my_course/my_course_list_service.dart';
import 'package:tms_app/domain/repositories/my_course/my_course_list_repository.dart';

class MyCourseListRepositoryImpl implements MyCourseListRepository {
  final MyCourseListService _service;

  MyCourseListRepositoryImpl(this._service);

  @override
  Future<MyCourseListResponse> getEnrolledCourses({
    required int accountId,
    required int page,
    required int size,
    required String status,
    String? title,
  }) async {
    try {
      // Call the service to fetch data from API
      final response = await _service.getEnrolledCourses(
        accountId: accountId,
        page: page,
        size: size,
        status: status,
        title: title,
      );

      return response;
    } catch (e) {
      // Log error
      print('Repository error fetching enrolled courses: $e');
      // Rethrow to be handled by upper layers
      rethrow;
    }
  }
}
