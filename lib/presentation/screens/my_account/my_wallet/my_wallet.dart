import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/payment.dart';

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String category;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    required this.icon,
  });
}

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  // Wallet balance
  final double _balance = 500000; // 500,000 VND

  // Theme colors
  late Color _backgroundColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _textSecondaryColor;
  late Color _dividerColor;
  late Color _shadowColor;

  // Mock transaction data
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      title: 'Nạp tiền vào tài khoản',
      description: 'Nạp tiền qua MoMo',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isIncome: true,
      category: 'Nạp tiền',
      icon: Icons.add_circle,
    ),
    Transaction(
      id: '2',
      title: 'Mua khóa học Flutter',
      description: 'Thanh toán khóa học Flutter cơ bản',
      amount: 150000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      isIncome: false,
      category: 'Khóa học',
      icon: Icons.school,
    ),
    Transaction(
      id: '3',
      title: 'Mua đề thi React Native',
      description: 'Thanh toán bộ đề thi React Native',
      amount: 50000,
      date: DateTime.now().subtract(const Duration(days: 8)),
      isIncome: false,
      category: 'Đề thi',
      icon: Icons.quiz,
    ),
    Transaction(
      id: '4',
      title: 'Hoàn tiền khóa học',
      description: 'Hoàn tiền khóa học JavaScript',
      amount: 120000,
      date: DateTime.now().subtract(const Duration(days: 15)),
      isIncome: true,
      category: 'Hoàn tiền',
      icon: Icons.replay,
    ),
    Transaction(
      id: '5',
      title: 'Nạp tiền vào tài khoản',
      description: 'Nạp tiền qua ngân hàng VCB',
      amount: 300000,
      date: DateTime.now().subtract(const Duration(days: 20)),
      isIncome: true,
      category: 'Nạp tiền',
      icon: Icons.add_circle,
    ),
  ];

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'MoMo',
      'icon': Icons.account_balance_wallet,
      'color': Colors.pink,
    },
    {
      'name': 'ZaloPay',
      'icon': Icons.wallet,
      'color': Colors.blue.shade800,
    },
  ];

  void _initializeColors(bool isDarkMode) {
    if (isDarkMode) {
      _backgroundColor = const Color(0xFF121212);
      _cardColor = const Color(0xFF1E1E1E);
      _textColor = Colors.white;
      _textSecondaryColor = Colors.white70;
      _dividerColor = Colors.grey.shade800;
      _shadowColor = Colors.black.withOpacity(0.3);
    } else {
      _backgroundColor = Colors.grey.shade100;
      _cardColor = Colors.white;
      _textColor = Colors.black;
      _textSecondaryColor = Colors.grey.shade800;
      _dividerColor = Colors.grey.shade200;
      _shadowColor = Colors.grey.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _initializeColors(isDarkMode);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Ví của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: _textColor),
            onPressed: () {
              // Show detailed transaction history
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            _buildBalanceCard(isDarkMode),

            // Actions
            _buildActionButtons(isDarkMode),

            // Payment methods
            _buildPaymentMethods(isDarkMode),

            // Recent transactions
            _buildRecentTransactions(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDarkMode) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(isDarkMode ? 0.4 : 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số dư ví',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TMS Wallet',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '05/25',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.add,
            label: 'Nạp tiền',
            color: Colors.green,
            onTap: () {
              _showDepositDialog(isDarkMode);
            },
            isDarkMode: isDarkMode,
          ),
          _buildActionButton(
            icon: Icons.send,
            label: 'Chuyển tiền',
            color: Colors.blue,
            onTap: () {
              // Handle transfer action
            },
            isDarkMode: isDarkMode,
          ),
          _buildActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Quét mã',
            color: Colors.purple,
            onTap: () {
              // Handle scan action
            },
            isDarkMode: isDarkMode,
          ),
          _buildActionButton(
            icon: Icons.receipt_long,
            label: 'Lịch sử',
            color: Colors.orange,
            onTap: () {
              // Handle history action
            },
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              return _buildPaymentMethodItem(
                name: method['name'],
                icon: method['icon'],
                color: method['color'],
                isDarkMode: isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required String name,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textColor,
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full transaction history
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _transactions.length > 3 ? 3 : _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return _buildTransactionItem(transaction, isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, bool isDarkMode) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? Colors.green.withOpacity(isDarkMode ? 0.2 : 0.1)
                  : Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.isIncome ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(transaction.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${transaction.isIncome ? '+' : '-'} ${formatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(bool isDarkMode) {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'momo';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
              title: Text(
                'Nạp tiền vào ví',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Số tiền (VND)',
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn phương thức thanh toán:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Payment method selection
                  Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => selectedMethod = 'momo'),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'momo',
                              groupValue: selectedMethod,
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => selectedMethod = value);
                              },
                              activeColor: Colors.pink,
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.pink;
                                  }
                                  return isDarkMode ? Colors.white70 : Colors.black54;
                                },
                              ),
                            ),
                            Icon(Icons.account_balance_wallet,
                                color: Colors.pink, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'MoMo',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => selectedMethod = 'zalopay'),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'zalopay',
                              groupValue: selectedMethod,
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => selectedMethod = value);
                              },
                              activeColor: Colors.blue,
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.blue;
                                  }
                                  return isDarkMode ? Colors.white70 : Colors.black54;
                                },
                              ),
                            ),
                            Icon(Icons.wallet,
                                color: Colors.blue.shade800, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ZaloPay',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await handleDepositPayment(
                      context: context,
                      amountText: amountController.text,
                      method: selectedMethod,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> handleDepositPayment({
    required BuildContext context,
    required String amountText,
    required String method, // 'momo' hoặc 'zalopay'
  }) async {
    // Kiểm tra số tiền
    final amount = int.tryParse(amountText.replaceAll('.', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Gọi API nạp tiền ở đây, ví dụ:
    // final result = await WalletService.deposit(amount: amount, method: method);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          paymentMethod: method,
          amount: amount.toDouble(), // Truyền tham số với giá tiền đã giảm
          items: [],
          promoCode: "",
          discountpercent: 0,
          paymentType: "WALLET",
        ),
      ),
    );

    // Giả lập thành công:
    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã gửi yêu cầu nạp $amount VND qua ${method == 'momo' ? 'MoMo' : 'ZaloPay'}!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
