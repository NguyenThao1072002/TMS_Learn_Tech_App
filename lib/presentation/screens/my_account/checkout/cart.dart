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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Tìm kiếm khóa học'),
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
              backgroundColor: Colors.blue,
            ),
            child: const Text('Tải lại giỏ hàng'),
          ),
        ],
      ),
    );
  }

  // Các widget stub cho các phần còn lại
  Widget _buildComboSuggestion() => const SizedBox.shrink();
  Widget _buildPromoCodeSection() => const SizedBox.shrink();
  Widget _buildOrderSummary() => const SizedBox.shrink();
  Widget _buildCheckoutBottomSheet() => Container();
}
