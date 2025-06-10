import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/models/payment/payment_history_model.dart';
import 'package:tms_app/domain/usecases/payment/payment_history_usecase.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int accountId;

  const PaymentHistoryScreen({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentHistoryUseCase _paymentHistoryUseCase = GetIt.instance<PaymentHistoryUseCase>();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  List<PaymentHistoryItem> _payments = [];
  List<PaymentHistoryItem> _filteredPayments = [];
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
    
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterPayments(_searchController.text);
  }
  
  void _filterPayments(String query) {
    setState(() {
      if (_selectedFilter.isEmpty) {
        _filteredPayments = _paymentHistoryUseCase.searchPayments(_payments, query);
      } else {
        final typeFiltered = _paymentHistoryUseCase.filterByType(_payments, _selectedFilter);
        _filteredPayments = _paymentHistoryUseCase.searchPayments(typeFiltered, query);
      }
    });
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final payments = await _paymentHistoryUseCase.getPaymentHistory(widget.accountId);

      setState(() {
        _payments = payments;
        _filteredPayments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lịch sử giao dịch",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPaymentHistory,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Text('Không có giao dịch nào'),
      );
    }

    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchPaymentHistory,
            child: _filteredPayments.isEmpty
                ? const Center(child: Text('Không tìm thấy giao dịch nào'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPayments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentItem(_filteredPayments[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Column(
        children: [
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm giao dịch...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              _filterPayments(value);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Bộ lọc
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', ''),
                const SizedBox(width: 8),
                _buildFilterChip('Khóa học', 'COURSE'),
                const SizedBox(width: 8),
                _buildFilterChip('Đề thi', 'EXAM'),
                const SizedBox(width: 8),
                _buildFilterChip('Combo', 'COMBO'),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Hiển thị tổng tiền đã chi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng chi:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  NumberFormat('#,###', 'vi_VN').format(_paymentHistoryUseCase.getTotalSpent(_payments)) + 'đ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : '';
          _filterPayments(_searchController.text);
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildPaymentItem(PaymentHistoryItem payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showPaymentDetails(payment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon phương thức thanh toán
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPaymentMethodIcon(payment.paymentMethod),
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Thông tin giao dịch
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mã giao dịch
                        Text(
                          'Mã GD: ${payment.transactionId}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Phương thức thanh toán và thời gian
                        Row(
                          children: [
                            Text(
                              payment.paymentMethod,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${payment.formattedDate} ${payment.formattedTime}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Số tiền
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('#,###', 'vi_VN').format(payment.totalPayment) + 'đ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (payment.isCombo)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Combo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // Hiển thị chi tiết sản phẩm nếu có
              if (payment.paymentDetails.isNotEmpty) ...[
                const Divider(height: 24),
                _buildPaymentDetails(payment),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(PaymentHistoryItem payment) {
    // Chỉ hiển thị tối đa 2 sản phẩm trong danh sách
    final displayCount = payment.paymentDetails.length > 2 ? 2 : payment.paymentDetails.length;
    final remainingCount = payment.paymentDetails.length - displayCount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayCount; i++)
          _buildProductItem(payment.paymentDetails[i]),
          
        // Hiển thị số lượng sản phẩm còn lại
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Và $remainingCount sản phẩm khác',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductItem(PaymentDetail detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon loại sản phẩm
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getProductTypeColor(detail.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getProductTypeIcon(detail.type),
              size: 14,
              color: _getProductTypeColor(detail.type),
            ),
          ),
          const SizedBox(width: 8),
          
          // Tên sản phẩm
          Expanded(
            child: Text(
              detail.title,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Giá sản phẩm
          Text(
            NumberFormat('#,###', 'vi_VN').format(detail.price) + 'đ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(PaymentHistoryItem payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildPaymentDetailsSheet(payment),
    );
  }

  Widget _buildPaymentDetailsSheet(PaymentHistoryItem payment) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết giao dịch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Chi tiết giao dịch
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Thông tin giao dịch
                  _buildDetailSection(
                    'Thông tin giao dịch',
                    [
                      _buildDetailRow('Mã giao dịch', payment.transactionId),
                      _buildDetailRow('Thời gian', '${payment.formattedDate} ${payment.formattedTime}'),
                      _buildDetailRow('Phương thức', payment.paymentMethod),
                      _buildDetailRow('Loại giao dịch', _formatPaymentType(payment.paymentType)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Danh sách sản phẩm
                  _buildDetailSection(
                    'Sản phẩm đã mua',
                    payment.paymentDetails.isEmpty
                        ? [_buildDetailRow('Chi tiết', 'Không có thông tin chi tiết')]
                        : payment.paymentDetails.map((detail) {
                            return _buildProductDetailRow(detail);
                          }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Thông tin thanh toán
                  _buildDetailSection(
                    'Thông tin thanh toán',
                    [
                      _buildDetailRow(
                        'Tổng tiền', 
                        NumberFormat('#,###', 'vi_VN').format(payment.totalPayment) + 'đ',
                        valueStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailRow(PaymentDetail detail) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon loại sản phẩm
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getProductTypeColor(detail.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getProductTypeIcon(detail.type),
              size: 18,
              color: _getProductTypeColor(detail.type),
            ),
          ),
          const SizedBox(width: 12),
          
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getProductTypeColor(detail.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatProductType(detail.type),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getProductTypeColor(detail.type),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Giá sản phẩm
          Text(
            NumberFormat('#,###', 'vi_VN').format(detail.price) + 'đ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'zalo pay':
        return Icons.payment;
      case 'momo':
        return Icons.wallet;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.credit_card;
    }
  }
  
  IconData _getProductTypeIcon(String type) {
    switch (type) {
      case 'EXAM':
        return Icons.description;
      case 'COURSE':
        return Icons.school;
      case 'COMBO':
        return Icons.shopping_bag;
      default:
        return Icons.shopping_cart;
    }
  }
  
  Color _getProductTypeColor(String type) {
    switch (type) {
      case 'EXAM':
        return Colors.orange;
      case 'COURSE':
        return Colors.green;
      case 'COMBO':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
  
  String _formatPaymentType(String type) {
    switch (type) {
      case 'PRODUCT':
        return 'Mua sản phẩm';
      default:
        return type;
    }
  }
  
  String _formatProductType(String type) {
    switch (type) {
      case 'EXAM':
        return 'Đề thi';
      case 'COURSE':
        return 'Khóa học';
      case 'COMBO':
        return 'Combo';
      default:
        return type;
    }
  }
} 