import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/payment.dart';
// import 'package:tms_appv/presentation/widgets/custom_text_field.dart';
// import 'package:tms_app/presentation/widgets/image_button.dart';
// import 'package:tms_learn_tech_app/utils/constants/color_constants.dart';
// import 'package:tms_app/utils/constants/constants.dart';
// import 'package:tms_app/utils/providers/cart_provider.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String type; // 'course' hoặc 'exam'
  bool isSelected; // Thêm trường isSelected
  final List<String> suggestedCombos; // Thêm thông tin về combo gợi ý

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.type,
    this.isSelected = false,
    this.suggestedCombos = const [],
  });
}

// Thêm lớp đối tượng combo
class CourseCombo {
  final String id;
  final String name;
  final List<String> courseIds;
  final int discountPercent;

  CourseCombo({
    required this.id,
    required this.name,
    required this.courseIds,
    required this.discountPercent,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CartScreen extends StatefulWidget {
  final String?
      preSelectedCourseId; // Thêm tham số để nhận ID khóa học cần chọn sẵn

  const CartScreen({Key? key, this.preSelectedCourseId}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Danh sách mẫu các mục trong giỏ hàng
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Khóa học Lập trình Flutter cơ bản',
      imageUrl: 'https://placehold.co/600x400/png',
      price: 299000,
      type: 'course',
      suggestedCombos: ['combo1'],
    ),
    CartItem(
      id: '2',
      title: 'Đề thi thử TOEIC 4 kỹ năng',
      imageUrl: 'https://placehold.co/600x400/png',
      price: 99000,
      type: 'exam',
    ),
    CartItem(
      id: '3',
      title: 'Khóa học Tiếng Anh giao tiếp',
      imageUrl: 'https://placehold.co/600x400/png',
      price: 399000,
      type: 'course',
      suggestedCombos: ['combo1', 'combo2'],
    ),
    CartItem(
      id: '4',
      title: 'Khóa học Lập trình ReactJS',
      imageUrl: 'https://placehold.co/600x400/png',
      price: 349000,
      type: 'course',
      suggestedCombos: ['combo1'],
    ),
  ];

  // Danh sách combo khóa học
  final List<CourseCombo> _availableCombos = [
    CourseCombo(
      id: 'combo1',
      name: 'Combo Lập trình Web & Mobile',
      courseIds: ['1', '3', '4'],
      discountPercent: 30,
    ),
    CourseCombo(
      id: 'combo2',
      name: 'Combo Tiếng Anh toàn diện',
      courseIds: ['3', '5'],
      discountPercent: 25,
    ),
  ];

  // Thêm biến theo dõi combo đã chọn
  String? _selectedComboId;

  // Danh sách phương thức thanh toán
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'tms_wallet',
      name: 'Ví TMS',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'momo',
      name: 'Ví MoMo',
      icon: Icons.wallet,
      color: Colors.pink,
    ),
    PaymentMethod(
      id: 'vnpay',
      name: 'VN Pay',
      icon: Icons.payment,
      color: Colors.red,
    ),
  ];

  // Phương thức thanh toán đã chọn
  String _selectedPaymentMethodId = 'tms_wallet';

  // Mã giảm giá
  String _promoCode = '';
  double _discountPercent = 0;
  bool _isApplyingPromo = false;
  bool _promoApplied = false;

  @override
  void initState() {
    super.initState();

    // Nếu có preSelectedCourseId, tự động tích chọn khóa học này
    if (widget.preSelectedCourseId != null) {
      // Tìm và chọn khóa học có ID tương ứng
      _selectPreselectedItem();
    }
  }

  // Phương thức chọn khóa học được gửi từ màn hình chi tiết
  void _selectPreselectedItem() {
    if (widget.preSelectedCourseId == null) return;

    for (var item in _cartItems) {
      if (item.id == widget.preSelectedCourseId) {
        setState(() {
          item.isSelected = true;
        });
        // Hiển thị thông báo đã thêm khóa học vào giỏ hàng
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Đã thêm khóa học vào giỏ hàng', Colors.green);
        });
        break;
      }
    }
  }

  // Hàm tính tổng tiền cho các mục đã chọn
  double get _totalSelectedAmount {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.price);
  }

  // Hàm tính số tiền giảm giá
  double get _discountAmount {
    return _totalSelectedAmount * _discountPercent / 100;
  }

  // Hàm tính số tiền cần thanh toán
  double get _finalAmount {
    return _totalSelectedAmount - _discountAmount;
  }

  // Kiểm tra xem có mục nào được chọn không
  bool get _hasSelectedItems {
    return _cartItems.any((item) => item.isSelected);
  }

  // Kiểm tra xem tất cả các mục có được chọn không
  bool get _allItemsSelected {
    return _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);
  }

  // Chọn/bỏ chọn tất cả các mục
  void _toggleSelectAll(bool? value) {
    if (value == null) return;

    setState(() {
      for (var item in _cartItems) {
        item.isSelected = value;
      }
    });
  }

  // Hàm xử lý áp dụng mã giảm giá
  void _applyPromoCode() {
    setState(() {
      _isApplyingPromo = true;
    });

    // Giả lập gọi API kiểm tra mã giảm giá
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isApplyingPromo = false;

        // Giả định WELCOME10 là mã giảm 10%, WELCOME20 là mã giảm 20%
        if (_promoCode == 'WELCOME10') {
          _discountPercent = 10;
          _promoApplied = true;
          _showSnackBar('Áp dụng mã giảm giá 10% thành công!', Colors.green);
        } else if (_promoCode == 'WELCOME20') {
          _discountPercent = 20;
          _promoApplied = true;
          _showSnackBar('Áp dụng mã giảm giá 20% thành công!', Colors.green);
        } else {
          _discountPercent = 0;
          _promoApplied = false;
          _showSnackBar('Mã giảm giá không hợp lệ!', Colors.red);
        }
      });
    });
  }

  // Hàm hiển thị SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hàm xóa item khỏi giỏ hàng
  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
    _showSnackBar('Đã xóa khỏi giỏ hàng', Colors.orange);
  }

  // Hàm xóa các mục đã chọn
  void _removeSelectedItems() {
    final selectedCount = _cartItems.where((item) => item.isSelected).length;

    setState(() {
      _cartItems.removeWhere((item) => item.isSelected);
    });

    _showSnackBar(
        'Đã xóa $selectedCount sản phẩm khỏi giỏ hàng', Colors.orange);
  }

  // Hàm chuyển đến màn hình xác nhận thanh toán
  void _proceedToCheckout() {
    if (!_hasSelectedItems) {
      _showSnackBar(
          'Vui lòng chọn ít nhất 1 sản phẩm để thanh toán', Colors.red);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCheckoutBottomSheet(),
    );
  }

  // Xử lý khi nhấn thanh toán
  void _processPayment() {
    Navigator.pop(context); // Đóng bottom sheet

    // Lấy danh sách các sản phẩm đã chọn
    final selectedItems = _cartItems
        .where((item) => item.isSelected)
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'price': item.price,
              'type': item.type,
            })
        .toList();

    // Chuyển đến màn hình thanh toán tương ứng với phương thức thanh toán đã chọn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          paymentMethod: _selectedPaymentMethodId,
          amount: _finalAmount,
          items: selectedItems,
        ),
      ),
    );
  }

  // Kiểm tra xem có combo nào khả dụng cho các item đã chọn hay không
  List<CourseCombo> get _availableComboSuggestions {
    if (!_hasSelectedItems) return [];

    final selectedIds = _cartItems
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toList();

    return _availableCombos.where((combo) {
      // Kiểm tra xem người dùng đã chọn ít nhất 2 khóa học trong combo
      int matchCount = 0;
      for (var id in selectedIds) {
        if (combo.courseIds.contains(id)) {
          matchCount++;
        }
      }
      return matchCount >= 2;
    }).toList();
  }

  // Lấy danh sách gợi ý khóa học để hoàn thiện combo
  List<CartItem> _getSuggestedItemsForCombo(CourseCombo combo) {
    final selectedIds = _cartItems
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toList();

    return _cartItems.where((item) {
      return !item.isSelected &&
          combo.courseIds.contains(item.id) &&
          !selectedIds.contains(item.id);
    }).toList();
  }

  // Áp dụng combo
  void _applyCombo(String comboId) {
    final combo = _availableCombos.firstWhere((c) => c.id == comboId);
    setState(() {
      _selectedComboId = comboId;
      _promoApplied = true;
      _discountPercent = combo.discountPercent.toDouble();
      _promoCode = combo.name;
    });
    _showSnackBar(
        'Đã áp dụng combo giảm ${combo.discountPercent}%', Colors.green);
  }

  // Chọn tất cả các khóa học trong một combo
  void _selectAllInCombo(String comboId) {
    final combo = _availableCombos.firstWhere((c) => c.id == comboId);
    setState(() {
      for (var item in _cartItems) {
        if (combo.courseIds.contains(item.id)) {
          item.isSelected = true;
        }
      }
    });
    _showSnackBar('Đã chọn tất cả khóa học trong combo', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_cartItems.isNotEmpty && _hasSelectedItems)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa mục đã chọn'),
                    content:
                        const Text('Bạn có chắc muốn xóa các mục đã chọn?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _removeSelectedItems();
                        },
                        child: const Text('Xóa',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                _buildSelectAllBar(),
                Expanded(
                  child: ListView(
                    children: [
                      ...List.generate(
                        _cartItems.length,
                        (index) => _buildCartItem(_cartItems[index]),
                      ),
                      if (_hasSelectedItems) ...[
                        _buildComboSuggestion(),
                        _buildPromoCodeSection(),
                        _buildOrderSummary(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _cartItems.isEmpty || !_hasSelectedItems
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiến hành thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Widget thanh chọn tất cả
  Widget _buildSelectAllBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(
            value: _allItemsSelected,
            onChanged: _toggleSelectAll,
            activeColor: Colors.blue,
          ),
          const Text(
            'Chọn tất cả',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_cartItems.where((item) => item.isSelected).length}/${_cartItems.length} đã chọn',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hãy thêm khóa học hoặc đề thi vào giỏ hàng',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Điều hướng đến trang khóa học
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Tìm kiếm khóa học'),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị item trong giỏ hàng
  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: item.isSelected ? 1 : 4, // Tăng độ đổ bóng khi không được chọn
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isSelected ? Colors.blue.shade300 : Colors.transparent,
          width: item.isSelected ? 1 : 0,
        ),
      ),
      color: item.isSelected
          ? Colors.blue.shade50
          : Colors.white, // Nền xanh nhẹ khi được chọn
      child: InkWell(
        onTap: () {
          setState(() {
            item.isSelected = !item.isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: item.isSelected,
                onChanged: (bool? value) {
                  if (value == null) return;
                  setState(() {
                    item.isSelected = value;
                  });
                },
                activeColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Hình ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(
                      item.type == 'course' ? Icons.book : Icons.quiz,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loại sản phẩm
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.type == 'course'
                            ? Colors.blue[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item.type == 'course' ? 'Khóa học' : 'Đề thi',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.type == 'course'
                              ? Colors.blue
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tiêu đề
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Giá
                    Text(
                      '${_formatCurrency(item.price)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút xóa
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeItem(item.id),
                color: Colors.grey,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị phần mã giảm giá
  Widget _buildPromoCodeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phần mã giảm giá
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.08),
                  Colors.blue.withOpacity(0.03)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.discount_outlined,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mã giảm giá',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                if (_promoApplied)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Đã áp dụng',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Phần nhập mã giảm giá
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _promoCode = value.trim().toUpperCase();
                                if (_promoApplied) {
                                  _promoApplied = false;
                                  _discountPercent = 0;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Nhập mã giảm giá',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 12, right: 8),
                                child: Icon(Icons.confirmation_number_outlined,
                                    size: 20, color: Colors.grey),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0, minHeight: 0),
                            ),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _promoCode.isEmpty ||
                                _isApplyingPromo ||
                                _promoApplied
                            ? null
                            : _applyPromoCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isApplyingPromo
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _promoApplied ? 'Đã áp dụng' : 'Áp dụng',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
                if (_promoApplied)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Áp dụng thành công: Giảm $_discountPercent%',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tổng tiền
  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phần tổng tiền
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.08),
                  Colors.blue.withOpacity(0.03)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_cartItems.where((item) => item.isSelected).length} sản phẩm',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chi tiết đơn hàng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                _buildOrderRow(
                  'Tổng tiền:',
                  '${_formatCurrency(_totalSelectedAmount)} đ',
                  isTotal: true,
                ),
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 12),
                  _buildOrderRow(
                    'Giảm giá (${_discountPercent.toInt()}%):',
                    '-${_formatCurrency(_discountAmount)} đ',
                    isDiscount: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDashedDivider(),
                  const SizedBox(height: 12),
                ],
                _buildFinalPrice('${_formatCurrency(_finalAmount)} đ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị 1 dòng thông tin đơn hàng
  Widget _buildOrderRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false, bool isFinal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isDiscount ? Colors.green[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị giá cuối cùng
  Widget _buildFinalPrice(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Thành tiền:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo đường gạch ngang cho phần thông tin đơn hàng
  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // Bottom sheet xác nhận thanh toán
  Widget _buildCheckoutBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với nút đóng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Phần còn lại cuộn được
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin khách hàng
                  _buildCustomerInfoSection(),

                  const SizedBox(height: 20),

                  // Danh sách sản phẩm đã chọn
                  _buildSelectedItemsSection(),

                  const SizedBox(height: 20),

                  // Phương thức thanh toán
                  _buildPaymentMethodsSection(),

                  const SizedBox(height: 20),

                  // Tổng tiền
                  _buildTotalSection(),
                ],
              ),
            ),
          ),

          // Nút thanh toán
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Thanh toán ngay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thông tin khách hàng
  Widget _buildCustomerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin khách hàng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildInfoRow('Họ tên:', 'Nguyễn Văn A'),
              const Divider(height: 20),
              _buildInfoRow('Email:', 'nguyenvana@example.com'),
              const Divider(height: 20),
              _buildInfoRow('Số điện thoại:', '0912345678'),
            ],
          ),
        ),
      ],
    );
  }

  // Dòng thông tin
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Danh sách sản phẩm đã chọn
  Widget _buildSelectedItemsSection() {
    final selectedItems = _cartItems.where((item) => item.isSelected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã chọn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (int i = 0; i < selectedItems.length; i++) ...[
                _buildSelectedItemRow(selectedItems[i]),
                if (i < selectedItems.length - 1) const Divider(height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Dòng sản phẩm đã chọn
  Widget _buildSelectedItemRow(CartItem item) {
    return Row(
      children: [
        // Icon loại sản phẩm
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.type == 'course' ? Colors.blue[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.type == 'course' ? Icons.book : Icons.quiz,
            color: item.type == 'course' ? Colors.blue : Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        // Tên sản phẩm
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 15),
        // Giá
        Text(
          '${_formatCurrency(item.price)} đ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // Phương thức thanh toán
  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: _paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethodId == method.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethodId = method.id;
                  });
                  // Đóng và mở lại bottom sheet để cập nhật UI
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _buildCheckoutBottomSheet(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: method.id != _paymentMethods.last.id
                            ? Colors.grey[200]!
                            : Colors.transparent,
                      ),
                    ),
                    color: isSelected ? Colors.blue.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method.icon,
                        color: method.color,
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        method.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      Radio<String>(
                        value: method.id,
                        groupValue: _selectedPaymentMethodId,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethodId = value;
                            });
                            // Đóng và mở lại bottom sheet để cập nhật UI
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _buildCheckoutBottomSheet(),
                            );
                          }
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Tổng tiền
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền:'),
              Text(
                '${_formatCurrency(_totalSelectedAmount)} đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giảm giá (${_discountPercent.toInt()}%):'),
                Text(
                  '-${_formatCurrency(_discountAmount)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thành tiền:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${_formatCurrency(_finalAmount)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Thêm phần gợi ý combo vào màn hình chính
  Widget _buildComboSuggestion() {
    final availableCombos = _availableComboSuggestions;

    if (availableCombos.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Gợi ý combo tiết kiệm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            // Thông tin tiết kiệm (đã xuống dòng)
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'Tiết kiệm đến ${availableCombos.map((c) => c.discountPercent).reduce((a, b) => a > b ? a : b)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),
            ...availableCombos.map((combo) => _buildComboItem(combo)).toList(),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị một combo gợi ý
  Widget _buildComboItem(CourseCombo combo) {
    final isSelected = _selectedComboId == combo.id;
    final suggestedItems = _getSuggestedItemsForCombo(combo);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  combo.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  '-${combo.discountPercent}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (suggestedItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text(
              'Thêm vào giỏ để nhận ưu đãi:',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...suggestedItems.map((item) => _buildSuggestedItem(item)).toList(),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (suggestedItems.isNotEmpty)
                OutlinedButton(
                  onPressed: () => _selectAllInCombo(combo.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Chọn tất cả'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isSelected ? null : () => _applyCombo(combo.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(isSelected ? 'Đã áp dụng' : 'Áp dụng'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget gợi ý khóa học cần thêm
  Widget _buildSuggestedItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            item.type == 'course' ? Icons.book : Icons.quiz,
            color: item.type == 'course' ? Colors.blue : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Tìm index của item trong danh sách
                final index = _cartItems.indexWhere((i) => i.id == item.id);
                if (index >= 0) {
                  _cartItems[index].isSelected = true;
                }
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }

  // Hàm format số tiền
  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
