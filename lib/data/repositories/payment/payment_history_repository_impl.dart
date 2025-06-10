import 'package:tms_app/data/models/payment/payment_history_model.dart';
import 'package:tms_app/data/services/payment/payment_history_service.dart';
import 'package:tms_app/domain/repositories/payment/payment_history_repository.dart';

/// Triển khai PaymentHistoryRepository
class PaymentHistoryRepositoryImpl implements PaymentHistoryRepository {
  final PaymentHistoryService _paymentHistoryService;

  PaymentHistoryRepositoryImpl(this._paymentHistoryService);

  /// Lấy lịch sử giao dịch của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch
  @override
  Future<List<PaymentHistoryItem>> getPaymentHistory(int accountId) async {
    try {
      final response = await _paymentHistoryService.getPaymentHistory(accountId);
      
      // Trả về danh sách các giao dịch
      return response.data;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }
} 