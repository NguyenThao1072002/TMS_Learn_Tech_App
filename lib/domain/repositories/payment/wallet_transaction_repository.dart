import 'package:tms_app/data/models/payment/wallet_transaction_model.dart';

/// Repository interface để lấy lịch sử giao dịch ví
abstract class WalletTransactionRepository {
  /// Lấy lịch sử giao dịch ví của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch ví
  /// [page] là số trang (bắt đầu từ 0)
  /// [size] là số lượng giao dịch trên mỗi trang
  Future<WalletTransactionResponse> getWalletTransactionHistory(
    int accountId, {
    int page = 0,
    int size = 10,
  });
} 