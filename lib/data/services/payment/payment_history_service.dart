import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/payment/payment_history_model.dart';
import 'package:tms_app/core/utils/constants.dart';

/// Service xử lý các tác vụ liên quan đến lịch sử giao dịch
class PaymentHistoryService {
  final Dio _dio;
  final String baseUrl = "${Constants.BASE_URL}/api";

  PaymentHistoryService(this._dio);
  
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

  /// Lấy lịch sử giao dịch của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch
  Future<PaymentHistoryResponse> getPaymentHistory(int accountId) async {
    try {
      // Lấy header xác thực
      final headers = await _getAuthHeaders();
      
      // Log debugging info
      print('Calling API for accountId: $accountId');
      print('API URL: $baseUrl/payments/history/$accountId');
      print('Headers: ${headers.toString()}');

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/payments/history/$accountId',
        options: Options(headers: headers),
      );
      
      // Log response data for debugging
      print('Response status code: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data keys: ${response.data is Map ? (response.data as Map).keys.toList() : "Not a map"}');

      // Validate response data
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      
      if (!(response.data is Map<String, dynamic>)) {
        throw Exception('Response data is not a Map<String, dynamic>: ${response.data.runtimeType}');
      }
      
      // Check required fields
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('status')) {
        throw Exception("Response missing 'status' field");
      }
      
      if (!data.containsKey('message')) {
        throw Exception("Response missing 'message' field");
      }
      
      if (!data.containsKey('data')) {
        throw Exception("Response missing 'data' field");
      }
      
      // Extra handling for data field - ensure it's a list
      final dataList = data['data'];
      if (dataList == null) {
        print('Warning: data is null, returning empty list');
        return PaymentHistoryResponse(
          status: data['status'] as int,
          message: data['message'] as String,
          data: [],
        );
      }
      
      if (!(dataList is List)) {
        throw Exception("'data' field is not a List: ${dataList.runtimeType}");
      }

      // Chuyển đổi dữ liệu
      return PaymentHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException occurred: ${e.type}, message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      throw _handleError(e);
    } catch (e) {
      print('Generic exception caught: ${e.runtimeType} - $e');
      throw Exception('Đã xảy ra lỗi khi lấy lịch sử giao dịch: $e');
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
        return Exception('Không tìm thấy dữ liệu lịch sử giao dịch');
      }

      if (responseData != null && responseData['message'] != null) {
        return Exception(responseData['message']);
      }
    }

    return Exception('Đã xảy ra lỗi khi lấy lịch sử giao dịch');
  }
} 