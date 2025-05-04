//chứa các hàm tiện ích (utility functions) để xử lý phản hồi API
//xử lý nhiều kiểu cấu trúc phản hồi API khác nhau

import 'package:tms_app/data/models/api_response_model.dart';

class ApiResponseHelper {
  /// Xử lý phản hồi API và trả về một danh sách đối tượng
  /// T là kiểu dữ liệu mục tiêu (ví dụ: CourseCardModel)
  /// fromJson là hàm chuyển đổi từ JSON sang đối tượng T
  static List<T> processList<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      print('[ApiResponseHelper] Xử lý dữ liệu: ${responseData.runtimeType}');

      // Xử lý khi responseData không phải là Map
      if (responseData is! Map<String, dynamic>) {
        // Kiểm tra nếu là List trực tiếp
        if (responseData is List) {
          print('[ApiResponseHelper] Phát hiện danh sách trực tiếp');
          return responseData
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        }
        print(
            '[ApiResponseHelper] Dữ liệu không phải là Map hoặc List: ${responseData.runtimeType}');
        return [];
      }

      final Map<String, dynamic> data = responseData;
      print(
          '[ApiResponseHelper] Các khóa trong phản hồi: ${data.keys.join(", ")}');

      // Trường hợp 1: API response có cấu trúc {status, message, data}
      if (data.containsKey('status') &&
          data.containsKey('message') &&
          data.containsKey('data')) {
        print(
            '[ApiResponseHelper] Phát hiện cấu trúc chuẩn: {status, message, data}');
        final apiData = data['data'];
        print(
            '[ApiResponseHelper] Kiểu dữ liệu của data: ${apiData.runtimeType}');

        // In ra tất cả các khóa trong data nếu có
        if (apiData is Map<String, dynamic>) {
          print(
              '[ApiResponseHelper] Các khóa trong data: ${apiData.keys.join(", ")}');
        }

        // Trường hợp 1.1: data là một mảng trực tiếp
        if (apiData is List) {
          print(
              '[ApiResponseHelper] Data là một mảng trực tiếp, số phần tử: ${apiData.length}');
          return apiData
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp 1.2: data là đối tượng phân trang có content
        else if (apiData is Map<String, dynamic>) {
          print(
              '[ApiResponseHelper] Data là một đối tượng: ${apiData.keys.join(", ")}');

          if (apiData.containsKey('content')) {
            final contentList = apiData['content'] as List;

            if (contentList.isEmpty) {
              return [];
            }

            try {
              final result = contentList
                  .map((item) => fromJson(item as Map<String, dynamic>))
                  .toList();
              return result;
            } catch (e) {
              print(
                  '[ApiResponseHelper] Stack trace: ${e is Error ? e.stackTrace : ""}');
              return [];
            }
          } else {
            return [];
          }
        }
        // Trường hợp khác của data
        else {
          return [];
        }
      }

      // Trường hợp 2: API response trực tiếp là đối tượng phân trang
      if (data.containsKey('content') && data['content'] is List) {
        final contentList = data['content'] as List;

        if (contentList.isEmpty) {
          return [];
        }

        try {
          final result = contentList
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          return result;
        } catch (e) {
          return [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Kiểm tra phản hồi API có thành công hay không
  static bool isSuccessResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('status')) {
      final status = responseData['status'];
      return status == 200 || status == "200";
    }
    return false;
  }

  /// Lấy thông báo từ phản hồi API
  static String getResponseMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      return responseData['message'].toString();
    }
    return "Unknown response";
  }

  /// Lấy tổng số trang từ phản hồi API phân trang
  static int getTotalPages(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Kiểm tra nếu là cấu trúc có data
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data'].containsKey('totalPages')) {
          return responseData['data']['totalPages'] as int;
        }

        // Kiểm tra nếu là cấu trúc phân trang trực tiếp
        if (responseData.containsKey('totalPages')) {
          return responseData['totalPages'] as int;
        }
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  /// Lấy tổng số phần tử từ phản hồi API phân trang
  static int getTotalElements(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Kiểm tra nếu là cấu trúc có data
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data'].containsKey('totalElements')) {
          return responseData['data']['totalElements'] as int;
        }

        // Kiểm tra nếu là cấu trúc phân trang trực tiếp
        if (responseData.containsKey('totalElements')) {
          return responseData['totalElements'] as int;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
