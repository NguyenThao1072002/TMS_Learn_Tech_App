import 'package:flutter/foundation.dart';
import 'package:tms_app/data/models/discount/discount_validation_response.dart';
import 'package:tms_app/domain/usecases/discount_usecase.dart';

class DiscountController {
  final DiscountUseCase _discountUseCase;

  // Value notifiers for UI state
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isVoucherValid = ValueNotifier<bool>(false);
  final ValueNotifier<String> successMessage = ValueNotifier<String>('');
  final ValueNotifier<DiscountValidationResponse?> voucherDetails =
      ValueNotifier<DiscountValidationResponse?>(null);
  final ValueNotifier<double> discountValue = ValueNotifier<double>(0.0);

  DiscountController({required DiscountUseCase discountUseCase})
      : _discountUseCase = discountUseCase;

  /// Kiểm tra mã voucher có hợp lệ không
  ///
  /// [voucherCode] là mã voucher cần kiểm tra
  /// [accountId] là ID tài khoản người dùng
  Future<bool> validateVoucher(String voucherCode, int accountId) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = '';
    isVoucherValid.value = false;
    voucherDetails.value = null;
    discountValue.value = 0.0;

    try {
      final result =
          await _discountUseCase.validateVoucher(voucherCode, accountId);

      isLoading.value = false;

      // Nếu status là 200 và data không null, voucher hợp lệ
      if (result.status == 200 && result.data != null) {
        isVoucherValid.value = true;
        successMessage.value = result.message;
        voucherDetails.value = result.data;
        discountValue.value = result.data.discountValue;
        return true;
      }
      // Nếu status là 400 hoặc bất kỳ mã lỗi nào khác
      else {
        errorMessage.value = result.message;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      // Xử lý lỗi khi gọi API
      if (e.toString().contains('400')) {
        errorMessage.value = 'Mã voucher không tồn tại';
      } else {
        errorMessage.value = e.toString();
      }
      return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    isVoucherValid.dispose();
    successMessage.dispose();
    voucherDetails.dispose();
    discountValue.dispose();
  }
}
