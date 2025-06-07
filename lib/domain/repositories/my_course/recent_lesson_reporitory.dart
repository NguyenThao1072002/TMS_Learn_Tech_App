import 'package:tms_app/data/models/my_course/recent_lesson_model.dart';

abstract class RecentLessonRepository {
  /// Get list of recently viewed lessons for a user
  Future<RecentLessonResponse> getRecentLessons(String userId);
}
