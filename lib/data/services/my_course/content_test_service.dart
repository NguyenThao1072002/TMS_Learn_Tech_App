import 'package:dio/dio.dart';
import 'package:tms_app/data/models/my_course/test/content_test_model.dart';

class ContentTestService {
  final Dio _dio;

  ContentTestService(this._dio);

  /// Lấy nội dung bài kiểm tra theo testId
  ///
  /// [testId] là ID của bài kiểm tra cần lấy
  Future<ContentTestResponse> getContentTest(int testId) async {
    try {
      final response = await _dio.get('/api/questions/test-mobile/$testId');

      return ContentTestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy nội dung bài kiểm tra: $e');
    }
  }

  /// Xử lý lỗi từ DioException
  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Hết thời gian kết nối, vui lòng thử lại sau');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Không có kết nối mạng, vui lòng kiểm tra lại');
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (statusCode == 404) {
        return Exception('Không tìm thấy bài kiểm tra');
      }

      if (responseData != null && responseData['message'] != null) {
        return Exception(responseData['message']);
      }
    }

    return Exception('Đã xảy ra lỗi khi lấy nội dung bài kiểm tra');
  }
}
