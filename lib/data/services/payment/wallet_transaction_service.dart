import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/payment/wallet_transaction_model.dart';
import 'package:tms_app/core/utils/constants.dart';

/// Service xử lý các tác vụ liên quan đến giao dịch ví
class WalletTransactionService {
  final Dio _dio;
  final String baseUrl = "${Constants.BASE_URL}/api";

  WalletTransactionService(this._dio);
  
  /// Lấy token xác thực từ SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }
  
  /// Lấy ID tài khoản người dùng hiện tại từ SharedPreferences
  Future<int?> getCurrentAccountId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Thử nhiều key khác nhau để lấy ID người dùng
      String? userId = prefs.getString('userId');
      
      if (userId == null || userId.isEmpty) {
        userId = prefs.getString('user_id');
      }
      
      if (userId == null || userId.isEmpty) {
        userId = prefs.getString('account_id');
      }
      
      if (userId == null || userId.isEmpty) {
        // Thử lấy từ SharedPrefs.KEY_USER_ID nếu có
        userId = prefs.getString('KEY_USER_ID');
      }
      
      // Thử lấy từ các key JWT token nếu cần
      if (userId == null || userId.isEmpty) {
        // Nếu không tìm thấy ID, trả về null
        print('Không tìm thấy ID người dùng trong SharedPreferences');
        return null;
      }

      // Chuyển đổi ID từ string sang int
      final accountId = int.tryParse(userId);
      print('Đã lấy được ID người dùng từ SharedPreferences: $accountId');
      return accountId;
    } catch (e) {
      print('Lỗi khi lấy ID người dùng từ SharedPreferences: $e');
      return null;
    }
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
  
  /// Lấy lịch sử giao dịch ví của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch ví
  /// [page] là số trang (bắt đầu từ 0)
  /// [size] là số lượng giao dịch trên mỗi trang
  Future<WalletTransactionResponse> getWalletTransactionHistory(
    int accountId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      // Lấy header xác thực
      final headers = await _getAuthHeaders();

      // Gọi API với tham số phân trang
      final response = await _dio.get(
        '$baseUrl/transactions/history/$accountId',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(headers: headers),
      );

      // Chuyển đổi dữ liệu
      return WalletTransactionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy lịch sử giao dịch ví: $e');
    }
  }
  
  /// Lấy lịch sử giao dịch ví của người dùng hiện tại
  /// 
  /// [page] là số trang (bắt đầu từ 0)
  /// [size] là số lượng giao dịch trên mỗi trang
  Future<WalletTransactionResponse> getCurrentUserWalletTransactions({
    int page = 0,
    int size = 10,
  }) async {
    final accountId = await getCurrentAccountId();
    
    if (accountId == null) {
      throw Exception('Không tìm thấy thông tin người dùng');
    }
    
    return getWalletTransactionHistory(accountId, page: page, size: size);
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
        return Exception('Không tìm thấy dữ liệu lịch sử giao dịch ví');
      }

      if (responseData != null && responseData['message'] != null) {
        return Exception(responseData['message']);
      }
    }

    return Exception('Đã xảy ra lỗi khi lấy lịch sử giao dịch ví');
  }
} 