import 'package:tms_app/data/models/my_course/learn_lesson_model.dart';

abstract class CourseLessonRepository {
  Future<CourseLessonResponse> getCourseLessons(int courseId);
}
