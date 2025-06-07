import 'package:tms_app/data/models/my_course/activate_model.dart';
import 'package:tms_app/data/services/my_course/activate_course_service.dart';
import 'package:tms_app/domain/repositories/my_course/activate_course_repository.dart';

class ActivateCourseRepositoryImpl implements ActivateCourseRepository {
  final ActivateCourseService _activateCourseService;

  ActivateCourseRepositoryImpl({
    required ActivateCourseService activateCourseService,
  }) : _activateCourseService = activateCourseService;

  @override
  Future<CheckCourseCodeResponse> checkCourseCode(CheckCourseCodeRequest request) async {
    try {
      return await _activateCourseService.checkCourseCode(request);
    } catch (e) {
      print('Error checking course code in repository: $e');
      throw Exception('Failed to check course code: $e');
    }
  }

  @override
  Future<bool> activateCourse(ActivateCourseRequest request) async {
    try {
      return await _activateCourseService.activateCourse(request);
    } catch (e) {
      print('Error activating course in repository: $e');
      throw Exception('Failed to activate course: $e');
    }
  }
}
