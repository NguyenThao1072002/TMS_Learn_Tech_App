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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ví của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
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
            _buildBalanceCard(),

            // Actions
            _buildActionButtons(),

            // Payment methods
            _buildPaymentMethods(),

            // Recent transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
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
            color: const Color(0xFF3498DB).withOpacity(0.3),
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

  Widget _buildActionButtons() {
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
              _showDepositDialog();
            },
          ),
          _buildActionButton(
            icon: Icons.send,
            label: 'Chuyển tiền',
            color: Colors.blue,
            onTap: () {
              // Handle transfer action
            },
          ),
          _buildActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Quét mã',
            color: Colors.purple,
            onTap: () {
              // Handle scan action
            },
          ),
          _buildActionButton(
            icon: Icons.receipt_long,
            label: 'Lịch sử',
            color: Colors.orange,
            onTap: () {
              // Handle history action
            },
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                  color: method['color']);
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
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
              color: color.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
              return _buildTransactionItem(transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
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
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(transaction.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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

  void _showDepositDialog() {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'momo';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nạp tiền vào ví'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VND)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chọn phương thức thanh toán:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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
                            ),
                            Icon(Icons.account_balance_wallet,
                                color: Colors.pink, size: 20),
                            const SizedBox(width: 8),
                            const Text('MoMo'),
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
                            ),
                            Icon(Icons.wallet,
                                color: Colors.blue.shade800, size: 20),
                            const SizedBox(width: 8),
                            const Text('ZaloPay'),
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
                  child: const Text('Hủy'),
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
