import 'package:tms_app/data/models/discount/discount_validation_response.dart';
import 'package:tms_app/data/services/discount_service.dart';
import 'package:tms_app/domain/repositories/discount_repository.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountService discountService;

  DiscountRepositoryImpl({required this.discountService});

  @override
  Future<ApiResponse<DiscountValidationResponse>> validateVoucher(
      String voucherCode, int accountId) async {
    try {
      return await discountService.validateVoucher(voucherCode, accountId);
    } catch (e) {
      // Tạo ApiResponse với dữ liệu lỗi
      if (e.toString().contains('400')) {
        return ApiResponse(
            status: 400,
            message: 'Mã voucher không tồn tại',
            data: DiscountValidationResponse(
              voucherCode: voucherCode,
              id: 0,
              discountValue: 0,
              format: 'VOUCHER',
              startDate: DateTime.now().toIso8601String(),
              endDate: DateTime.now().toIso8601String(),
            ));
      } else {
        return ApiResponse(
            status: 500,
            message: 'Lỗi khi kiểm tra mã giảm giá: ${e.toString()}',
            data: DiscountValidationResponse(
              voucherCode: voucherCode,
              id: 0,
              discountValue: 0,
              format: 'VOUCHER',
              startDate: DateTime.now().toIso8601String(),
              endDate: DateTime.now().toIso8601String(),
            ));
      }
    }
  }
}
