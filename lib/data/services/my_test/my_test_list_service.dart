import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/my_test/my_test_list_model.dart';
import 'package:tms_app/data/models/my_test/test_result_model.dart';
import 'package:tms_app/data/models/my_test/test_result_detail_model.dart';
import 'package:tms_app/data/models/my_test/test_answer_model.dart';
import 'package:tms_app/core/utils/constants.dart';

/// Service xử lý các tác vụ liên quan đến danh sách đề thi
class MyTestListService {
  final Dio _dio;
  final String baseUrl = "${Constants.BASE_URL}/api";

  MyTestListService(this._dio);
  
  /// Lấy token xác thực từ SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }
  
  /// Tạo header xác thực với token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cache-Control': 'no-cache',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Lấy danh sách đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  Future<MyTestResponse> getTestsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      // Xây dựng query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      // Thêm tham số search nếu có
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Lấy header xác thực
      final headers = await _getAuthHeaders();

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/tests/by-account-exam/$accountId',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      // Chuyển đổi dữ liệu
      return MyTestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy danh sách đề thi: $e');
    }
  }

  /// Lấy danh sách kết quả đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy kết quả đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  Future<TestResultResponse> getTestResultsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      // Xây dựng query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      // Thêm tham số search nếu có
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Lấy header xác thực
      final headers = await _getAuthHeaders();

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/tests/by-account-exam-result/$accountId',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      // Chuyển đổi dữ liệu
      return TestResultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy danh sách kết quả đề thi: $e');
    }
  }

  /// Lấy danh sách các kết quả làm bài của một bài kiểm tra cụ thể
  /// 
  /// [testId] là ID của bài kiểm tra cần lấy kết quả
  /// [accountId] là ID của tài khoản (nếu cần lọc theo tài khoản cụ thể)
  Future<TestResultDetailResponse> getTestResultsByTest(
    int testId, {
    int? accountId,
  }) async {
    try {
      // Xây dựng query parameters
      final Map<String, dynamic> queryParams = {};
      
      // Thêm accountId vào query parameters nếu có
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      // Lấy header xác thực
      final headers = await _getAuthHeaders();

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/test-results/by-test/$testId',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      // Chuyển đổi dữ liệu
      return TestResultDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy danh sách kết quả làm bài: $e');
    }
  }
  
  /// Lấy chi tiết câu trả lời của một bài làm cụ thể
  /// 
  /// [accountId] là ID của tài khoản đã làm bài
  /// [testId] là ID của bài kiểm tra
  /// [testResultId] là ID của kết quả bài làm cần lấy chi tiết
  Future<TestAnswerResponse> getTestAnswers({
    required int accountId,
    required int testId,
    required int testResultId,
  }) async {
    try {
      // Xây dựng query parameters
      final Map<String, dynamic> queryParams = {
        'accountId': accountId,
        'testId': testId,
        'testResultId': testResultId,
      };

      // Lấy header xác thực
      final headers = await _getAuthHeaders();

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/test-results/get-answer-test',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      // In ra log để debug
      print('Test Answers API Response: ${response.data}');

      // Chuyển đổi dữ liệu
      return TestAnswerResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      print('Test Answers Error: $e');
      throw Exception('Đã xảy ra lỗi khi lấy chi tiết câu trả lời: $e');
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

      if (statusCode == 401) {
        return Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      }

      if (statusCode == 403) {
        return Exception('Bạn không có quyền truy cập tài nguyên này');
      }

      if (statusCode == 404) {
        return Exception('Không tìm thấy dữ liệu đề thi');
      }

      if (responseData != null && responseData['message'] != null) {
        return Exception(responseData['message']);
      }
    }

    return Exception('Đã xảy ra lỗi khi lấy danh sách đề thi');
  }
}
