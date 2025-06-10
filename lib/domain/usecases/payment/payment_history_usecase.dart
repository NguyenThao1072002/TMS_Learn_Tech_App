import 'package:tms_app/data/models/payment/payment_history_model.dart';
import 'package:tms_app/domain/repositories/payment/payment_history_repository.dart';

/// UseCase xử lý các tác vụ liên quan đến lịch sử giao dịch
class PaymentHistoryUseCase {
  final PaymentHistoryRepository _paymentHistoryRepository;

  PaymentHistoryUseCase(this._paymentHistoryRepository);

  /// Lấy lịch sử giao dịch của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch
  Future<List<PaymentHistoryItem>> getPaymentHistory(int accountId) async {
    return await _paymentHistoryRepository.getPaymentHistory(accountId);
  }

  /// Lấy danh sách các giao dịch gần đây nhất
  /// 
  /// [payments] là danh sách các giao dịch
  /// [count] là số lượng giao dịch cần lấy (mặc định là 3)
  List<PaymentHistoryItem> getRecentPayments(List<PaymentHistoryItem> payments, {int count = 3}) {
    final sortedPayments = List<PaymentHistoryItem>.from(payments);
    
    // Sắp xếp theo thời gian thanh toán mới nhất
    sortedPayments.sort((a, b) => 
      b.paymentDate.compareTo(a.paymentDate));
    
    // Trả về [count] giao dịch gần nhất
    return sortedPayments.take(count).toList();
  }

  /// Tính tổng số tiền đã thanh toán
  /// 
  /// [payments] là danh sách các giao dịch
  double getTotalSpent(List<PaymentHistoryItem> payments) {
    return payments.fold(0, (sum, payment) => sum + payment.totalPayment);
  }

  /// Tìm kiếm giao dịch theo từ khóa
  /// 
  /// [payments] là danh sách các giao dịch
  /// [query] là từ khóa tìm kiếm
  List<PaymentHistoryItem> searchPayments(List<PaymentHistoryItem> payments, String query) {
    if (query.isEmpty) return payments;
    
    final lowercaseQuery = query.toLowerCase();
    
    return payments.where((payment) {
      // Tìm theo mã giao dịch
      if (payment.transactionId.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Tìm theo phương thức thanh toán
      if (payment.paymentMethod.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Tìm theo chi tiết sản phẩm
      for (final detail in payment.paymentDetails) {
        if (detail.title.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }
  
  /// Lọc giao dịch theo loại sản phẩm
  /// 
  /// [payments] là danh sách các giao dịch
  /// [type] là loại sản phẩm cần lọc (EXAM, COURSE, COMBO)
  List<PaymentHistoryItem> filterByType(List<PaymentHistoryItem> payments, String type) {
    if (type.isEmpty) return payments;
    
    return payments.where((payment) {
      // Kiểm tra có chi tiết sản phẩm không
      if (payment.paymentDetails.isEmpty) return false;
      
      // Kiểm tra loại sản phẩm
      return payment.paymentDetails.any((detail) => detail.type == type);
    }).toList();
  }
} 