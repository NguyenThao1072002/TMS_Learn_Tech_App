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

      // Gọi API
      final response = await _dio.get(
        '$baseUrl/payments/history/$accountId',
        options: Options(headers: headers),
      );

      // Chuyển đổi dữ liệu
      return PaymentHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
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