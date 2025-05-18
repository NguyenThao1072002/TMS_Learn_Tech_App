import 'package:tms_app/data/models/my_course/learn_lesson_model.dart';
import 'package:tms_app/data/services/my_course/course_lesson_service.dart';
import 'package:tms_app/domain/repositories/my_course/course_lesson_repository.dart';

class CourseLessonRepositoryImpl implements CourseLessonRepository {
  final CourseLessonService _service;

  CourseLessonRepositoryImpl(this._service);

  @override
  Future<CourseLessonResponse> getCourseLessons(int courseId) async {
    try {
      final result = await _service.getCourseLessons(courseId);
      return result;
    } catch (e) {
      print('Error in CourseLessonRepositoryImpl: $e');
      throw Exception('Failed to fetch course lessons: $e');
    }
  }
}
