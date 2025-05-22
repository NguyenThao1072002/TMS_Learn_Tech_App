import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/discount/discount_validation_response.dart';
import 'package:get_it/get_it.dart';

class DiscountService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  DiscountService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  /// Kiểm tra mã voucher có hợp lệ không
  ///
  /// [voucherCode] là mã voucher cần kiểm tra
  /// [accountId] là ID tài khoản người dùng
  Future<ApiResponse<DiscountValidationResponse>> validateVoucher(
      String voucherCode, int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token not found. Please login again.");
    }

    final url =
        '$baseUrl/api/discounts/payment/validate?voucherCode=$voucherCode&accountId=$accountId';

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // Thành công - status 200
      if (response.statusCode == 200) {
        // Kiểm tra status từ API response
        if (response.data['status'] == 200) {
          return ApiResponse.fromJson(
            response.data,
            (data) => DiscountValidationResponse.fromJson(data),
          );
        } else {
          // API trả về lỗi trong response body
          return ApiResponse(
            status: response.data['status'] ?? 400,
            message: response.data['message'] ?? 'Mã voucher không hợp lệ',
            data: DiscountValidationResponse(
              voucherCode: voucherCode,
              id: 0,
              discountValue: 0,
              format: 'VOUCHER',
              startDate: DateTime.now().toIso8601String(),
              endDate: DateTime.now().toIso8601String(),
            ),
          );
        }
      } else {
        throw DioError(
          response: response,
          requestOptions: RequestOptions(path: url),
          error: 'Failed to validate voucher: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      // DioError - xử lý lỗi từ API
      if (e.response != null) {
        if (e.response!.data != null && e.response!.data is Map) {
          // Lấy message từ response nếu có
          final errorMessage =
              e.response!.data['message'] ?? 'Lỗi không xác định';
          return ApiResponse(
            status: e.response!.statusCode ?? 400,
            message: errorMessage,
            data: DiscountValidationResponse(
              voucherCode: voucherCode,
              id: 0,
              discountValue: 0,
              format: 'VOUCHER',
              startDate: DateTime.now().toIso8601String(),
              endDate: DateTime.now().toIso8601String(),
            ),
          );
        }
      }
      throw Exception('Failed to validate voucher: ${e.message}');
    } catch (e) {
      throw Exception('Failed to validate voucher: $e');
    }
  }
}
