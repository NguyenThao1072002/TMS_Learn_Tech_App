// Service cho bình luận bài học

import 'package:dio/dio.dart';
import 'package:tms_app/data/models/my_course/comment_lession_model.dart';
import 'package:tms_app/data/models/my_course/like_comment_model.dart';
import 'package:tms_app/core/utils/constants.dart';

/// Service xử lý các request API liên quan đến bình luận bài học
class CommentLessonService {
  final Dio _dio;
  final String baseUrl = "${Constants.BASE_URL}/api";

  CommentLessonService(this._dio);

  /// Lấy danh sách bình luận của bài học
  ///
  /// [videoId] ID của video bài học
  /// [lessonId] ID của bài học
  /// [targetType] Loại đối tượng được bình luận (COURSE, LESSON, VIDEO)
  /// [page] Số trang (mặc định là 0)
  /// [size] Số lượng bình luận mỗi trang (mặc định là 20)
  Future<CommentLessonResponse> getComments({
    required int videoId,
    required int lessonId,
    required String targetType,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final endpoint = '$baseUrl/comments/course';
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'videoId': videoId,
          'lessonId': lessonId,
          'targetType': targetType,
          'page': page,
          'size': size,
        },
      );

      return CommentLessonResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Không thể tải bình luận');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải bình luận: $e');
    }
  }

  /// Like hoặc unlike một bình luận
  /// 
  /// [commentId] ID của bình luận
  /// [accountId] ID của tài khoản
  Future<LikeCommentResponse> likeComment({
    required int commentId,
    required int accountId,
  }) async {
    try {
      final endpoint = '$baseUrl/comments/$commentId/like';
      final response = await _dio.post(
        endpoint,
        queryParameters: {
          'accountId': accountId,
        },
      );

      return LikeCommentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Không thể thực hiện like/dislike bình luận');
    } catch (e) {
      throw Exception('Lỗi không xác định khi like/dislike bình luận: $e');
    }
  }

  /// Xử lý lỗi từ DioException
  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (responseData is Map<String, dynamic> &&
          responseData['message'] != null) {
        return Exception(responseData['message']);
      } else {
        return Exception('$defaultMessage (Mã lỗi: $statusCode)');
      }
    } else {
      return Exception('$defaultMessage: ${e.message}');
    }
  }
}
