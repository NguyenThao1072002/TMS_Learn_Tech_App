import 'package:tms_app/data/models/payment/wallet_transaction_model.dart';
import 'package:tms_app/domain/repositories/payment/wallet_transaction_repository.dart';
import 'package:tms_app/data/services/payment/wallet_transaction_service.dart';

/// Implementation của WalletTransactionRepository
class WalletTransactionRepositoryImpl implements WalletTransactionRepository {
  /// Service xử lý các tác vụ liên quan đến giao dịch ví
  final WalletTransactionService _walletTransactionService;

  /// Constructor
  WalletTransactionRepositoryImpl(this._walletTransactionService);

  @override
  Future<WalletTransactionResponse> getWalletTransactionHistory(
    int accountId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      // Gọi service để lấy dữ liệu
      final response = await _walletTransactionService.getWalletTransactionHistory(
        accountId,
        page: page,
        size: size,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
} 