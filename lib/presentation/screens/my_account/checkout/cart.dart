import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/presentation/controller/cart_controller.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/payment.dart';

// Định nghĩa lớp CourseCombo
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

// Định nghĩa lớp PaymentMethod
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

// Định nghĩa lớp CartScreen
class CartScreen extends StatefulWidget {
  final String? preSelectedCourseId;
  final String? preSelectedItemId;
  final String? preSelectedItemType; // Thêm type để biết loại item được chọn

  const CartScreen({
    Key? key,
    this.preSelectedCourseId,
    this.preSelectedItemId,
    this.preSelectedItemType = 'COURSE', // Mặc định là khóa học
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Sử dụng trực tiếp CartController
  late CartController _cartController;

  // Danh sách lưu trữ các mục đã chọn (sử dụng cartItemId)
  final Map<int, bool> _selectedItems = {};

  // Biến để theo dõi nếu đã quá thời gian chờ loading
  bool _loadingTimedOut = false;

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

  String? _selectedComboId;
  String _selectedPaymentMethodId = 'tms_wallet';
  String _promoCode = '';
  double _discountPercent = 0;
  bool _isApplyingPromo = false;
  bool _promoApplied = false;

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

  @override
  void initState() {
    super.initState();

    // Khởi tạo CartController
    _cartController = CartController(
      cartUseCase: GetIt.instance<CartUseCase>(),
    );

    // Thêm cơ chế timeout cho loading
    _setupLoadingTimeout();

    // Tải dữ liệu giỏ hàng với cơ chế retry
    _loadCartWithRetry();

    // Nếu có preSelectedItemId, tự động tích chọn sau khi dữ liệu được tải
    if (widget.preSelectedItemId != null) {
      _cartController.cartItems.addListener(_checkPreSelectedItem);
    }
  }

  void _setupLoadingTimeout() {
    // Nếu sau 8 giây mà vẫn đang loading, reset trạng thái
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;

      if (_cartController.isLoading.value) {
        _cartController.isLoading.value = false;
        _loadingTimedOut = true;

        // Hiển thị thông báo
        _showSnackBar('Tải giỏ hàng quá lâu, vui lòng thử lại', Colors.orange);

        // Buộc cập nhật UI
        setState(() {});
      }
    });
  }

  Future<void> _loadCartWithRetry() async {
    try {
      await _cartController.loadCartItems();
    } catch (e) {
      // Tự động thử lại sau 2 giây
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted &&
              _cartController.cartItems.value.isEmpty &&
              !_loadingTimedOut) {
            _cartController.loadCartItems();
          }
        });
      }
    }
  }

  // Kiểm tra preSelectedItemId khi danh sách giỏ hàng thay đổi
  void _checkPreSelectedItem() {
    if (widget.preSelectedItemId == null) return;
    if (_cartController.cartItems.value.isEmpty) return;

    // Chỉ chạy một lần khi dữ liệu được tải
    _cartController.cartItems.removeListener(_checkPreSelectedItem);
    _selectPreselectedItem();
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên
    _cartController.dispose();
    super.dispose();
  }

  // Phương thức chọn item được gửi từ màn hình chi tiết
  void _selectPreselectedItem() {
    if (widget.preSelectedItemId == null || widget.preSelectedItemType == null)
      return;

    final items = _cartController.cartItems.value;
    for (var item in items) {
      // Kiểm tra dựa vào type và id của item
      bool isMatch = false;

      // Xác định loại item dựa vào type
      switch (widget.preSelectedItemType?.toUpperCase()) {
        case 'COURSE':
          isMatch = item.courseId != null &&
              item.courseId.toString() == widget.preSelectedItemId;
          break;
        case 'EXAM':
          isMatch = item.testId != null &&
              item.testId.toString() == widget.preSelectedItemId;
          break;
        case 'COMBO':
          isMatch = item.courseBundleId != null &&
              item.courseBundleId.toString() == widget.preSelectedItemId;
          break;
        default:
          break;
      }

      if (isMatch) {
        setState(() {
          _selectedItems[item.cartItemId] = true;
        });
        _showSnackBar(
            'Đã thêm ${_getDisplayTextForType(item.type).toLowerCase()} vào giỏ hàng',
            Colors.green);
        break;
      }
    }
  }

  // Hiển thị SnackBar thông báo
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Tính tổng tiền các mục đã chọn
  double get _totalSelectedAmount {
    return _cartController.cartItems.value
        .where((item) => _selectedItems[item.cartItemId] == true)
        .fold(0, (sum, item) => sum + item.price);
  }

  // Tính số tiền giảm giá
  double get _discountAmount {
    return _totalSelectedAmount * _discountPercent / 100;
  }

  // Tính số tiền cần thanh toán
  double get _finalAmount {
    return _totalSelectedAmount - _discountAmount;
  }

  // Kiểm tra có mục nào được chọn không
  bool get _hasSelectedItems {
    return _selectedItems.values.contains(true);
  }

  // Kiểm tra tất cả các mục có được chọn không
  bool get _allItemsSelected {
    final items = _cartController.cartItems.value;
    return items.isNotEmpty &&
        items.every((item) => _selectedItems[item.cartItemId] == true);
  }

  // Phương thức chọn/bỏ chọn tất cả
  void _toggleSelectAll(bool? value) {
    if (value == null) return;

    setState(() {
      for (var item in _cartController.cartItems.value) {
        _selectedItems[item.cartItemId] = value;
      }
    });
  }

  // Phương thức xóa item khỏi giỏ hàng
  void _removeItem(int cartItemId) {

    print('Bắt đầu xóa item có ID: $cartItemId');
    
    _cartController.removeFromCart(cartItemId).then((success) {
      if (success) {
        setState(() {
          // Xóa item khỏi danh sách đã chọn
          _selectedItems.remove(cartItemId);
        });
        _showSnackBar('Đã xóa khỏi giỏ hàng', Colors.orange);
  
      } else {
        _showSnackBar('Không thể xóa sản phẩm. Vui lòng thử lại sau.', Colors.red);
      }
    }).catchError((error) {
      print('Lỗi khi xóa item: $error');
      _showSnackBar('Đã xảy ra lỗi: ${error.toString()}', Colors.red);
    }).whenComplete(() {
      setState(() {
        _cartController.isLoading.value = false;
      });
    });
  }

  // Phương thức xóa các mục đã chọn
  void _removeSelectedItems() {
    final selectedItems = _cartController.cartItems.value
        .where((item) => _selectedItems[item.cartItemId] == true)
        .toList();

    final selectedCount = selectedItems.length;

    for (var item in selectedItems) {
      _cartController.removeFromCart(item.cartItemId).then((success) {
        // Xóa khỏi danh sách đã chọn
        setState(() {
          _selectedItems.remove(item.cartItemId);
        });
      });
    }

    _showSnackBar(
        'Đã xóa $selectedCount sản phẩm khỏi giỏ hàng', Colors.orange);
  }

  // Phương thức tiến hành thanh toán
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
    final selectedItems = _cartController.cartItems.value
        .where((item) => _selectedItems[item.cartItemId] == true)
        .map((item) => {
              'id': _getItemId(item),
              'title': item.name,
              'price': item.price,
              'type': item.type,
            })
        .toList();

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

  // Hàm helper để lấy ID của item dựa vào loại
  String _getItemId(CartItem item) {
    if (item.courseId != null) {
      return item.courseId.toString();
    } else if (item.testId != null) {
      return item.testId.toString();
    } else if (item.courseBundleId != null) {
      return item.courseBundleId.toString();
    }
    return '';
  }

  // Hàm format số tiền
  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
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
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: _cartController.cartItems,
            builder: (context, items, _) {
              if (items.isNotEmpty && _hasSelectedItems) {
                return IconButton(
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _cartController.isLoading,
        builder: (context, isLoading, _) {
          // Hiển thị loading indicator
          if (isLoading && !_loadingTimedOut) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Đang tải giỏ hàng..."),
                ],
              ),
            );
          }

          return ValueListenableBuilder<List<CartItem>>(
            valueListenable: _cartController.cartItems,
            builder: (context, items, _) {
              // Kiểm tra error state
              if (_cartController.errorMessage.value != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _cartController.errorMessage.value!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _cartController.loadCartItems,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              // Kiểm tra nếu giỏ hàng trống
              if (items.isEmpty) {
                return _buildEmptyCart();
              }

              // Hiển thị danh sách sản phẩm
              return Column(
                children: [
                  _buildSelectAllBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cartController.refresh,
                      child: ListView(
                        children: [
                          ...items.map((item) => _buildCartItem(item)).toList(),
                          if (_hasSelectedItems) ...[
                            _buildComboSuggestion(),
                            _buildPromoCodeSection(),
                            _buildOrderSummary(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: _cartController.cartItems,
        builder: (context, items, _) {
          if (items.isEmpty || !_hasSelectedItems) {
            return const SizedBox(height: 0);
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(76),
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
          );
        },
      ),
    );
  }

  // Widget hiển thị thanh chọn tất cả
  Widget _buildSelectAllBar() {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: _cartController.cartItems,
      builder: (context, items, _) {
        final selectedCount = items
            .where((item) => _selectedItems[item.cartItemId] == true)
            .length;

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
                '$selectedCount/${items.length} đã chọn',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị item trong giỏ hàng
  Widget _buildCartItem(CartItem item) {
    final isSelected = _selectedItems[item.cartItemId] == true;
    final productTypeDisplay = _getDisplayTextForType(item.type);
    final productTypeColor = _getColorForType(item.type);
    final productTypeIcon = _getIconForType(item.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: isSelected ? 1 : 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade300 : Colors.transparent,
          width: isSelected ? 1 : 0,
        ),
      ),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedItems[item.cartItemId] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedItems[item.cartItemId] = value;
                  });
                },
                activeColor: Colors.blue,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(productTypeIcon,
                          color: Colors.grey[500], size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: productTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        productTypeDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: productTypeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.price > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_formatCurrency(item.price)} đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Miễn phí',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    if (item.discount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Giảm ${item.discount}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeItem(item.cartItemId),
                color: Colors.grey,
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm trả về văn bản hiển thị cho từng loại sản phẩm
  String _getDisplayTextForType(String type) {
    switch (type.toUpperCase()) {
      case 'COURSE':
        return 'Khóa học';
      case 'EXAM':
        return 'Đề thi';
      case 'COMBO':
        return 'Combo';
      default:
        return type; // Hiển thị nguyên bản nếu không nhận diện được
    }
  }

  // Hàm trả về màu sắc cho từng loại sản phẩm
  Color _getColorForType(String type) {
    switch (type.toUpperCase()) {
      case 'COURSE':
        return Colors.blue;
      case 'EXAM':
        return Colors.orange;
      case 'COMBO':
        return Colors.purple;
      default:
        return Colors.grey; // Màu mặc định
    }
  }

  // Hàm trả về icon cho từng loại sản phẩm
  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'COURSE':
        return Icons.book;
      case 'EXAM':
        return Icons.quiz;
      case 'COMBO':
        return Icons.card_giftcard;
      default:
        return Icons.shopping_bag; // Icon mặc định
    }
  }

  // Widget hiển thị khi giỏ hàng trống
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
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Khám phá khóa học'),
          ),
          // Thêm nút thử lại
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Thử tải lại
              setState(() {
                _cartController.loadCartItems();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Tải lại giỏ hàng'),
          ),
        ],
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
                    '${_selectedItems.values.where((selected) => selected).length} sản phẩm',
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

  // Phương thức xử lý áp dụng mã giảm giá
  void _applyPromoCode() {
    setState(() {
      _isApplyingPromo = true;
    });

    // Giả lập API call với delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // Giả định kiểm tra mã khuyến mãi (trong thực tế sẽ gọi API)
      final validPromos = {
        'WELCOME': 10,
        'TET2024': 20,
        'SUMMER': 15,
        'TMS50': 50,
      };

      setState(() {
        _isApplyingPromo = false;

        if (validPromos.containsKey(_promoCode)) {
          _discountPercent = validPromos[_promoCode]!.toDouble();
          _promoApplied = true;
          _showSnackBar('Áp dụng mã giảm giá thành công!', Colors.green);
        } else {
          _promoApplied = false;
          _discountPercent = 0;
          _showSnackBar('Mã giảm giá không hợp lệ hoặc đã hết hạn', Colors.red);
        }
      });
    });
  }

  // Widget hiển thị dòng thông tin đơn hàng
  Widget _buildOrderRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: FontWeight.bold,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị giá cuối cùng
  Widget _buildFinalPrice(String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
          'Thành tiền:',
            style: TextStyle(
            fontSize: 18,
              fontWeight: FontWeight.bold,
            color: Colors.blue,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
            fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
    );
  }

  // Widget hiển thị đường kẻ ngang đứt đoạn
  Widget _buildDashedDivider() {
    return Container(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const dashWidth = 5.0;
          const dashSpace = 3.0;
          final dashCount = (width / (dashWidth + dashSpace)).floor();

        return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
              return Container(
              width: dashWidth,
                height: 1,
                color: Colors.grey.withOpacity(0.3),
            );
          }),
          );
        },
      ),
    );
  }

  // Các widget stub cho các phần còn lại
  Widget _buildComboSuggestion() => const SizedBox.shrink();
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

  // Widget hiển thị thông tin khách hàng
  Widget _buildCustomerInfoSection() {
    return Container(
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
          // Tiêu đề phần thông tin khách hàng
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
                  child: const Icon(Icons.person_outline,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Thông tin khách hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Thông tin khách hàng
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.account_circle_outlined, 'Họ và tên:',
                    'Nguyễn Văn A'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.email_outlined, 'Email:', 'nguyenvana@gmail.com'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.phone_outlined, 'Số điện thoại:', '0987654321'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách sản phẩm đã chọn
  Widget _buildSelectedItemsSection() {
    final selectedItems = _cartController.cartItems.value
        .where((item) => _selectedItems[item.cartItemId] == true)
        .toList();

    return Container(
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
          // Tiêu đề phần sản phẩm
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
                  child: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Sản phẩm đã chọn',
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
                    '${selectedItems.length} sản phẩm',
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

          // Danh sách sản phẩm đã chọn
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedItems.length,
            itemBuilder: (context, index) {
              final item = selectedItems[index];
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hình ảnh sản phẩm
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(_getIconForType(item.type),
                                color: Colors.grey[500], size: 30),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Thông tin sản phẩm
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getColorForType(item.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getDisplayTextForType(item.type),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getColorForType(item.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Giá sản phẩm
                    Text(
                      '${_formatCurrency(item.price)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget hiển thị phương thức thanh toán
  Widget _buildPaymentMethodsSection() {
    return Container(
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
          // Tiêu đề phần phương thức thanh toán
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
                  child: const Icon(Icons.payment_outlined,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách phương thức thanh toán
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              final isSelected = _selectedPaymentMethodId == method.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethodId = method.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: index < _paymentMethods.length - 1 ? 1 : 0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: method.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          method.icon,
                          color: method.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        method.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Radio<String>(
                        value: method.id,
                        groupValue: _selectedPaymentMethodId,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethodId = value;
                            });
                          }
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tổng tiền trong bottom sheet
  Widget _buildTotalSection() {
    return Container(
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
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Chi tiết tổng tiền
          Padding(
            padding: const EdgeInsets.all(15),
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

  // Widget hiển thị dòng thông tin
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
