import 'package:tms_app/data/models/my_course/activate_model.dart';

abstract class ActivateCourseRepository {
  /// Check if a course code is valid and not already activated
  Future<CheckCourseCodeResponse> checkCourseCode(CheckCourseCodeRequest request);
  
  /// Activate a course with student data
  Future<bool> activateCourse(ActivateCourseRequest request);
}
