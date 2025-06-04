import 'package:dio/dio.dart';
import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/core/utils/constants.dart';

/// Service xử lý các API liên quan đến tiến trình học tập
class CourseProgressService {
  final Dio _dio;

  /// Constructor
  CourseProgressService(this._dio);
  final String baseUrl = "${Constants.BASE_URL}";

  /// Thêm tiến trình mới khi người dùng bắt đầu học khóa học
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  Future<CourseProgressResponse> addCourseProgress(
      String accountId, int courseId) async {
    try {
      final response = await _dio.post(
        '${baseUrl}/api/progress/add',
        queryParameters: {
          'accountId': accountId,
          'courseId': courseId,
        },
      );

      return CourseProgressResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // /// Cập nhật tiến trình học tập của người dùng
  // ///
  // /// [progressModel] Model chứa thông tin tiến trình cần cập nhật
  // Future<CourseProgressResponse> updateCourseProgress(
  //     CourseProgressModel progressModel) async {
  //   try {
  //     final response = await _dio.put(
  //       '${ApiConstants.baseUrl}/api/progress/update',
  //       data: progressModel.toJson(),
  //     );

  //     return CourseProgressResponse.fromJson(response.data);
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  // /// Lấy tiến trình học tập của người dùng cho một khóa học cụ thể
  // ///
  // /// [accountId] ID của tài khoản người dùng
  // /// [courseId] ID của khóa học
  // Future<CourseProgressModel> getCourseProgress(
  //     int accountId, int courseId) async {
  //   try {
  //     final response = await _dio.get(
  //       '${ApiConstants.baseUrl}/api/progress',
  //       queryParameters: {
  //         'accountId': accountId,
  //         'courseId': courseId,
  //       },
  //     );

  //     return CourseProgressModel.fromJson(response.data['data']);
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  /// Xử lý lỗi từ API
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final message = error.response!.data['message'] ?? 'Lỗi không xác định';

        return Exception('Lỗi $statusCode: $message');
      }
      return Exception('Lỗi kết nối: ${error.message}');
    }
    return Exception('Đã xảy ra lỗi: $error');
  }
}
