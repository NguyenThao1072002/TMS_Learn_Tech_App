import 'package:tms_app/data/models/discount/discount_validation_response.dart';

abstract class DiscountRepository {
  /// Kiểm tra mã voucher có hợp lệ không
  ///
  /// [voucherCode] là mã voucher cần kiểm tra
  /// [accountId] là ID tài khoản người dùng
  Future<ApiResponse<DiscountValidationResponse>> validateVoucher(
      String voucherCode, int accountId);
}
