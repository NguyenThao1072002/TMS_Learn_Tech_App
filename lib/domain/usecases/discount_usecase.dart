import 'package:tms_app/data/models/discount/discount_validation_response.dart';
import 'package:tms_app/domain/repositories/discount_repository.dart';

class DiscountUseCase {
  final DiscountRepository _discountRepository;

  DiscountUseCase(this._discountRepository);

  /// Kiểm tra mã voucher có hợp lệ không
  ///
  /// [voucherCode] là mã voucher cần kiểm tra
  /// [accountId] là ID tài khoản người dùng
  Future<ApiResponse<DiscountValidationResponse>> validateVoucher(
      String voucherCode, int accountId) async {
    if (voucherCode.isEmpty) {
      throw Exception('Voucher code cannot be empty');
    }

    return await _discountRepository.validateVoucher(voucherCode, accountId);
  }
}
