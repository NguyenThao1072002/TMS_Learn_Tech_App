import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/data/models/payment/wallet_transaction_model.dart';
import 'package:tms_app/domain/usecases/payment/wallet_transaction_history_usecase.dart';

class WalletTransactionHistoryScreen extends StatefulWidget {
  final int accountId;
  
  const WalletTransactionHistoryScreen({
    Key? key, 
    required this.accountId,
  }) : super(key: key);

  @override
  State<WalletTransactionHistoryScreen> createState() => _WalletTransactionHistoryScreenState();
}

class _WalletTransactionHistoryScreenState extends State<WalletTransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<WalletTransaction> _transactions = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _currentPage < _totalPages - 1) {
        _loadMoreTransactions();
      }
    });
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final useCase = sl<WalletTransactionHistoryUseCase>();
      final response = await useCase.execute(
        widget.accountId,
        page: 0,
      );
      
      setState(() {
        _transactions = response.data.content;
        _totalPages = response.data.totalPages;
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = sl<WalletTransactionHistoryUseCase>();
      final response = await useCase.execute(
        widget.accountId,
        page: _currentPage + 1,
      );
      
      setState(() {
        _transactions.addAll(response.data.content);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch ví'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading && _transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError && _transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã xảy ra lỗi: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Text('Chưa có giao dịch nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _transactions.length + (_isLoading && _currentPage > 0 ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          if (index < _transactions.length) {
            return _buildTransactionItem(_transactions[index], isDarkMode);
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction, bool isDarkMode) {
    // Format số tiền
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedAmount = currencyFormatter.format(transaction.amount);
    
    // Format thời gian
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final date = dateFormatter.format(transaction.transactionDate);
    final time = timeFormatter.format(transaction.transactionDate);
    
    // Icon và màu sắc tùy theo loại giao dịch
    IconData transactionIcon;
    Color iconColor;
    
    switch (transaction.transactionType) {
      case "TOP_UP":
        transactionIcon = Icons.add_circle_outline;
        iconColor = Colors.green;
        break;
      case "PAYMENT":
        transactionIcon = Icons.shopping_cart_outlined;
        iconColor = Colors.red;
        break;
      default:
        transactionIcon = Icons.swap_horiz;
        iconColor = Colors.blue;
    }
    
    return InkWell(
      onTap: () => _showTransactionDetails(transaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon giao dịch
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              radius: 24,
              child: Icon(
                transactionIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin giao dịch
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã GD: #${transaction.transactionId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date lúc $time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Số tiền
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.transactionType == "TOP_UP" ? "+ $formattedAmount" : "- $formattedAmount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.transactionType == "TOP_UP" ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.transactionStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(transaction.transactionStatus),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(transaction.transactionStatus),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTransactionDetails(WalletTransaction transaction) {
    // Format số tiền
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedAmount = currencyFormatter.format(transaction.amount);
    
    // Format thời gian
    final dateTimeFormatter = DateFormat('HH:mm - dd/MM/yyyy');
    final dateTime = dateTimeFormatter.format(transaction.transactionDate);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              transaction.transactionType == "TOP_UP" ? Icons.add_circle_outline : Icons.shopping_cart_outlined,
              color: transaction.transactionType == "TOP_UP" ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Chi tiết giao dịch'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Mã giao dịch', '#${transaction.transactionId}'),
            _buildDetailRow('Loại giao dịch', _getTransactionTypeText(transaction.transactionType)),
            _buildDetailRow('Số tiền', formattedAmount),
            _buildDetailRow('Thời gian', dateTime),
            _buildDetailRow('Trạng thái', _getStatusText(transaction.transactionStatus)),
            _buildDetailRow('Mô tả', transaction.description),
            if (transaction.externalTransactionId != null)
              _buildDetailRow('Mã GD ngoài', transaction.externalTransactionId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'SUCCESS':
        return 'Thành công';
      case 'PENDING':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      default:
        return 'Không xác định';
    }
  }
  
  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'TOP_UP':
        return 'Nạp tiền';
      case 'PAYMENT':
        return 'Thanh toán';
      default:
        return 'Khác';
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 