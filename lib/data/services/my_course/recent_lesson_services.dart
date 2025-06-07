import 'package:dio/dio.dart';
import 'package:tms_app/data/models/my_course/recent_lesson_model.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/core/network/dio_client.dart';
import 'package:get_it/get_it.dart';
class RecentLessonService {
  final Dio _dio;
  final String apiUrl = "${Constants.BASE_URL}/api";
  late final DioClient _dioClient;
  RecentLessonService(this._dio) {
    // Lấy DioClient từ service locator
    _dioClient = GetIt.instance<DioClient>();
  }

  /// Fetch recent lessons viewed by the user
  Future<RecentLessonResponse> getRecentLessons(String userId) async {
    try {
      final response = await _dioClient.get(
        '$apiUrl/activity/view-lesson-lasted/$userId',
      );

      return RecentLessonResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch recent lessons: $e');
    }
  }
}
