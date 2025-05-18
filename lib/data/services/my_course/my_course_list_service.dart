import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/my_course/my_course_list_model.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/core/network/dio_client.dart';
import 'package:get_it/get_it.dart';

class MyCourseListService {
  final Dio _dio;
  final String apiUrl = "${Constants.BASE_URL}/api";
  late final DioClient _dioClient;

  MyCourseListService(this._dio) {
    // Lấy DioClient từ service locator
    _dioClient = GetIt.instance<DioClient>();
  }

  /// Calls the API to get enrolled courses for a user
  Future<MyCourseListResponse> getEnrolledCourses({
    required int accountId,
    required int page,
    required int size,
    required String status,
    String? title,
  }) async {
    try {
      // Build the URL with query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        'status': status,
      };

      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      final endpoint = '$apiUrl/courses/account/enrolled/$accountId';
      print('Đang gọi API: $endpoint với tham số: $queryParams');

      // Sử dụng DioClient để tự động kiểm tra token
      final response = await _dioClient.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        requiresAuth: true, // Yêu cầu token
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final responseData = response.data;

        // Kiểm tra cấu trúc phản hồi
        if (responseData is Map<String, dynamic>) {
          // Trường hợp có wrapper (status, message, data)
          if (responseData.containsKey('data') &&
              responseData['data'] is Map<String, dynamic>) {
            print('API trả về cấu trúc có wrapper, parse từ trường "data"');
            return MyCourseListResponse.fromJson(responseData['data']);
          }
          // Trường hợp không có wrapper, dữ liệu trực tiếp
          else if (responseData.containsKey('content') ||
              responseData.containsKey('totalElements')) {
            print('API trả về cấu trúc không có wrapper, parse trực tiếp');
            return MyCourseListResponse.fromJson(responseData);
          }
          // Không tìm thấy cấu trúc dữ liệu phù hợp
          else {
            print('Cấu trúc API không khớp với mô hình: ${responseData.keys}');
            throw Exception('Cấu trúc dữ liệu không phù hợp');
          }
        } else {
          throw Exception('Dữ liệu trả về không hợp lệ');
        }
      } else {
        print('Lỗi API (${response.statusCode}): ${response.data}');
        throw Exception('Lỗi khi tải khóa học: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Lỗi Dio khi lấy khóa học đã đăng ký: $e');
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      // Log error and rethrow
      print('Lỗi khi lấy khóa học đã đăng ký: $e');
      throw Exception('Không thể tải danh sách khóa học: $e');
    }
  }
}
