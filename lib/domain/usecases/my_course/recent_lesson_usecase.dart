import 'package:tms_app/data/models/my_course/recent_lesson_model.dart';
import 'package:tms_app/domain/repositories/my_course/recent_lesson_reporitory.dart';

/// Use case to get the recently viewed lessons for a user
class RecentLessonUseCase {
  final RecentLessonRepository _repository;

  RecentLessonUseCase(this._repository);

  /// Get the list of recently viewed lessons for a user
  /// 
  /// [userId] is the ID of the user
  Future<RecentLessonResponse> execute(String userId) async {
    return await _repository.getRecentLessons(userId);
  }
}
