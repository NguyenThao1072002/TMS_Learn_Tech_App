import 'package:tms_app/data/models/payment/wallet_transaction_model.dart';
import 'package:tms_app/domain/repositories/payment/wallet_transaction_repository.dart';

/// UseCase để lấy lịch sử giao dịch ví của người dùng
class WalletTransactionHistoryUseCase {
  /// Repository xử lý lịch sử giao dịch ví
  final WalletTransactionRepository _repository;

  /// Constructor
  WalletTransactionHistoryUseCase(this._repository);

  /// Lấy lịch sử giao dịch ví của một tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy lịch sử giao dịch ví
  /// [page] là số trang (bắt đầu từ 0)
  /// [size] là số lượng giao dịch trên mỗi trang
  Future<WalletTransactionResponse> execute(
    int accountId, {
    int page = 0,
    int size = 10,
  }) async {
    return await _repository.getWalletTransactionHistory(
      accountId,
      page: page,
      size: size,
    );
  }
} 