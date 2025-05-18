import 'package:tms_app/data/models/my_course/learn_lesson_model.dart';
import 'package:tms_app/domain/repositories/my_course/course_lesson_repository.dart';

class CourseLessonUseCase {
  final CourseLessonRepository _repository;

  CourseLessonUseCase(this._repository);

  Future<CourseLessonResponse> getCourseLessons(int courseId) async {
    return await _repository.getCourseLessons(courseId);
  }
}
