import 'package:tms_app/data/models/my_course/recent_lesson_model.dart';
import 'package:tms_app/data/services/my_course/recent_lesson_services.dart';
import 'package:tms_app/domain/repositories/my_course/recent_lesson_reporitory.dart';

class RecentLessonRepositoryImpl implements RecentLessonRepository {
  final RecentLessonService _recentLessonService;

  RecentLessonRepositoryImpl(this._recentLessonService);

  @override
  Future<RecentLessonResponse> getRecentLessons(String userId) async {
    try {
      return await _recentLessonService.getRecentLessons(userId);
    } catch (e) {
      print('Error in RecentLessonRepositoryImpl: $e');
      throw Exception('Failed to fetch recent lessons: $e');
    }
  }
}
