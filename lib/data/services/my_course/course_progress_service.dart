import 'package:dio/dio.dart';
import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/my_course/completed_lession_model.dart';
import 'package:tms_app/data/models/my_course/test_submission_model.dart';

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

  /// Mở khóa bài học tiếp theo khi người dùng hoàn thành bài học hiện tại
  ///
  /// [accountId] ID của tài khoản người dùng
  /// [courseId] ID của khóa học
  /// [chapterId] ID của chương học
  /// [lessonId] ID của bài học hiện tại
  Future<UnlockNextLessonResponse> unlockNextLesson(
      String accountId, int courseId, int chapterId, int lessonId) async {
    try {
      print(
          '🔄 Đang gọi API mở khóa bài học tiếp theo với accountId=$accountId, courseId=$courseId, chapterId=$chapterId, lessonId=$lessonId');

      final response = await _dio.post(
        '${baseUrl}/api/progress/unlock-next',
        queryParameters: {
          'accountId': accountId,
          'courseId': courseId,
          'chapterId': chapterId,
          'lessonId': lessonId,
        },
      );

      print('✅ Đã mở khóa bài học tiếp theo thành công');
      return UnlockNextLessonResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Kiểm tra lỗi kết nối và thử lại
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        print('⚠️ Lỗi kết nối khi mở khóa bài học tiếp theo, đang thử lại...');

        // Đợi 2 giây và thử lại
        await Future.delayed(const Duration(seconds: 2));

        try {
          final retryResponse = await _dio.post(
            '${baseUrl}/api/progress/unlock-next',
            queryParameters: {
              'accountId': accountId,
              'courseId': courseId,
              'chapterId': chapterId,
              'lessonId': lessonId,
            },
          );

          print('✅ Đã mở khóa bài học tiếp theo thành công sau khi thử lại');
          return UnlockNextLessonResponse.fromJson(retryResponse.data);
        } catch (retryError) {
          throw _handleError(retryError);
        }
      }

      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gửi câu trả lời bài kiểm tra
  ///
  /// [request] Dữ liệu yêu cầu gửi bài kiểm tra
  Future<dynamic> submitTestAnswers(TestSubmissionRequest request) async {
    try {
      print('🔄 Đang gửi câu trả lời bài kiểm tra...');
      print('   - TestId: ${request.testId}');
      print('   - CourseId: ${request.courseId}');
      print('   - ChapterId: ${request.chapterId}');
      print('   - IsChapterTest: ${request.isChapterTest}');
      print('   - TotalQuestion: ${request.totalQuestion}');

      final response = await _dio.post(
        '${baseUrl}/api/questions/submit-answers',
        data: request.toJson(),
      );

      print('✅ Đã gửi câu trả lời bài kiểm tra thành công');

      // Phân biệt loại response dựa vào isChapterTest
      if (request.isChapterTest) {
        print('📋 Kết quả bài kiểm tra chương: ${response.data['message']}');
        return ChapterTestSubmissionResponse.fromJson(response.data);
      } else {
        print('📊 Điểm số: ${response.data['data']['score']}');
        print('📋 Kết quả: ${response.data['data']['resultTest']}');
        return TestSubmissionResponse.fromJson(response.data);
      }
    } on DioException catch (e) {
      // Kiểm tra lỗi kết nối và thử lại
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        print(
            '⚠️ Lỗi kết nối khi gửi câu trả lời bài kiểm tra, đang thử lại...');

        // Đợi 2 giây và thử lại
        await Future.delayed(const Duration(seconds: 2));

        try {
          final retryResponse = await _dio.post(
            '${baseUrl}/api/questions/submit-answers',
            data: request.toJson(),
          );
          print(request.toJson()); // In dữ liệu response từ server
          print(
              '${baseUrl}/api/questions/submit-answers'); // In ra URL đúng cách

          print('✅ Đã gửi câu trả lời bài kiểm tra thành công sau khi thử lại');

          // Phân biệt loại response dựa vào isChapterTest
          if (request.isChapterTest) {
            return ChapterTestSubmissionResponse.fromJson(retryResponse.data);
          } else {
            return TestSubmissionResponse.fromJson(retryResponse.data);
          }
        } catch (retryError) {
          throw _handleError(retryError);
        }
      }

      throw _handleError(e);
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
