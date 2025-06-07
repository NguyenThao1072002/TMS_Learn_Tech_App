import 'package:tms_app/data/models/my_course/activate_model.dart';
import 'package:tms_app/domain/repositories/my_course/activate_course_repository.dart';

class CheckCourseCodeUseCase {
  final ActivateCourseRepository _repository;

  CheckCourseCodeUseCase(this._repository);

  Future<CheckCourseCodeResponse> execute(CheckCourseCodeRequest request) async {
    return await _repository.checkCourseCode(request);
  }
}

class ActivateCourseUseCase {
  final ActivateCourseRepository _repository;

  ActivateCourseUseCase(this._repository);

  Future<bool> execute(ActivateCourseRequest request) async {
    return await _repository.activateCourse(request);
  }
}
