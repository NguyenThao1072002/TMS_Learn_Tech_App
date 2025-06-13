import 'package:tms_app/data/models/payment/payment_history_model.dart';

/// Interface định nghĩa các phương thức làm việc với lịch sử giao dịch
abstract class PaymentHistoryRepository {
  /// Lấy lịch sử giao dịch của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch
  Future<List<PaymentHistoryItem>> getPaymentHistory(int accountId);
} 