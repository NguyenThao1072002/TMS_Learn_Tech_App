import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/data/models/combo/course_bundle_model.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/cart_controller.dart';
import 'package:tms_app/domain/usecases/discount_usecase.dart';
import 'package:tms_app/domain/usecases/payment_usecase.dart';
import 'package:tms_app/presentation/controller/payment_controller.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/payment.dart';
import 'package:tms_app/presentation/widgets/course/combo_course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/controller/discount_controller.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';

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
  late CourseController _courseController;

  // Biến để lưu thông tin chi tiết của combo đang được chọn
  ComboCourseDetailModel? _selectedComboDetail;

  late final PaymentController _paymentController;
  late final DiscountController _discountController;
  static const EventChannel eventChannel =
      EventChannel('flutter.native/eventPayOrder');

  static const MethodChannel platform =
      MethodChannel('flutter.native/channelPayOrder');

  // Danh sách lưu trữ các mục đã chọn (sử dụng cartItemId)
  final Map<int, bool> _selectedItems = {};

  // Use ValueNotifier for payment method ID to ensure UI updates
  final ValueNotifier<String> _selectedPaymentMethodIdNotifier =
      ValueNotifier<String>('tms_wallet');

  // Biến để theo dõi nếu đã quá thời gian chờ loading
  bool _loadingTimedOut = false;
  String paymentResult = "";
  bool _isLoadingComboDetail = false;
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
  String payResult = "";
  String? _selectedComboId;
  String _promoCode = '';
  double _discountPercent = 0;
  bool _isApplyingPromo = false;
  bool _promoApplied = false;

  final PaymentUseCase _paymentUseCase = GetIt.instance<PaymentUseCase>();
  final DiscountUseCase _discountUseCase = GetIt.instance<DiscountUseCase>();

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
      id: 'zalopay',
      name: 'ZaloPay',
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

    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }
    // Khởi tạo CartController
    _cartController = CartController(
      cartUseCase: GetIt.instance<CartUseCase>(),
    );

    // Khởi tạo CourseController
    _courseController = CourseController(
      GetIt.instance<CourseUseCase>(),
    );

    // Initialize PaymentController
    // _paymentController = GetIt.instance<PaymentController>();

    _paymentController = PaymentController(paymentUseCase: _paymentUseCase);
    _discountController = DiscountController(discountUseCase: _discountUseCase);
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
  Future<void> _selectPreselectedItem() async {
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

        // Nếu là khóa học thì tải gợi ý combo
        if (item.type.toUpperCase() == 'COURSE' && item.courseId != null) {
          _cartController.loadCourseBundles(item.courseId!);
        } else if (item.type.toUpperCase() == 'COMBO' &&
            item.courseBundleId != null) {
          await _loadComboDetail(item.courseBundleId!);
        }
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
  Future<void> _toggleSelectAll(bool? value) async {
    if (value == null) return;

    // Nếu bỏ chọn tất cả thì đơn giản là set tất cả về false
    if (!value) {
      setState(() {
        for (var item in _cartController.cartItems.value) {
          _selectedItems[item.cartItemId] = false;
        }

        // Xóa thông tin chi tiết combo và gợi ý
        _selectedComboDetail = null;
        _cartController.suggestedBundles.value = [];
      });
      return;
    }

    // Nếu chọn tất cả, ưu tiên combo và không chọn khóa học đã có trong combo
    setState(() {
      _selectedItems.clear(); // Reset lại toàn bộ lựa chọn
    });

    // Danh sách các mục trong giỏ hàng
    final items = _cartController.cartItems.value;

    // Lọc danh sách combo và khóa học
    final combos =
        items.where((item) => item.type.toUpperCase() == 'COMBO').toList();
    final courses =
        items.where((item) => item.type.toUpperCase() == 'COURSE').toList();
    final others = items
        .where((item) =>
            item.type.toUpperCase() != 'COMBO' &&
            item.type.toUpperCase() != 'COURSE')
        .toList();

    // Bước 1: Chọn tất cả combo trước
    for (var combo in combos) {
      setState(() {
        _selectedItems[combo.cartItemId] = true;
      });

      // Tải chi tiết combo để lấy danh sách khóa học trong combo
      if (combo.courseBundleId != null) {
        try {
          await _loadComboDetail(combo.courseBundleId!);
        } catch (e) {
          print('Lỗi tải chi tiết combo khi chọn tất cả: $e');
        }
      }
    }

    // Bước 2: Lấy tất cả ID khóa học đã có trong các combo đã chọn
    Set<int> coursesInSelectedCombos = {};
    if (_selectedComboDetail != null) {
      coursesInSelectedCombos =
          _selectedComboDetail!.courses.map((c) => c.id).toSet();
    }

    // Nếu có nhiều combo đã chọn, cần tải thông tin chi tiết của từng combo
    for (var combo in combos) {
      if (combo.courseBundleId != null &&
          _selectedItems[combo.cartItemId] == true) {
        try {
          final comboDetail =
              await _courseController.getComboDetail(combo.courseBundleId!);
          if (comboDetail != null) {
            coursesInSelectedCombos
                .addAll(comboDetail.courses.map((c) => c.id));
          }
        } catch (e) {
          print('Lỗi khi tải chi tiết combo ${combo.name}: $e');
        }
      }
    }

    // Bước 3: Chỉ chọn các khóa học không thuộc combo đã chọn
    for (var course in courses) {
      if (course.courseId != null &&
          !coursesInSelectedCombos.contains(course.courseId)) {
        setState(() {
          _selectedItems[course.cartItemId] = true;
        });
      } else {
        setState(() {
          _selectedItems[course.cartItemId] = false;
        });
      }
    }

    // Bước 4: Chọn các loại item khác
    for (var item in others) {
      setState(() {
        _selectedItems[item.cartItemId] = true;
      });
    }

    // Tải gợi ý combo cho khóa học đầu tiên được chọn (nếu có)
    final selectedCourses = courses
        .where((item) =>
            _selectedItems[item.cartItemId] == true && item.courseId != null)
        .toList();

    if (selectedCourses.isNotEmpty) {
      _cartController.loadCourseBundles(selectedCourses.first.courseId!);
    }
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
        _showSnackBar(
            'Không thể xóa sản phẩm. Vui lòng thử lại sau.', Colors.red);
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

  void _onEvent(dynamic event) {
    print("_onEvent: '$event'.");
    var res = Map<String, dynamic>.from(event);
    setState(() {
      if (res["errorCode"] == 1) {
        payResult = "Thanh toán thành công";
      } else if (res["errorCode"] == 4) {
        payResult = "User hủy thanh toán";
      } else {
        payResult = "Giao dịch thất bại";
      }
    });
  }

  void _onError(Object error) {
    print("_onError: '$error'.");
    setState(() {
      payResult = "Giao dịch thất bại";
    });
  }

  Future<Map<String, dynamic>> _payWithZaloPay(String zpToken) async {
    try {
      final result =
          await platform.invokeMethod('payOrder', {'zptoken': zpToken});

      // print('ZaloPay result: $result');

      // Ép kiểu rõ ràng
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'status': 'error',
        'message': e.message ?? 'Lỗi không xác định từ PlatformException'
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi không xác định: $e'};
    }
  }

  Future<void> subscribe() async {
    eventChannel.receiveBroadcastStream().listen(
      (data) {
        var res = Map<String, dynamic>.from(data);
        String message;
        if (res["errorCode"] == 1) {
          message = "Payment succees";
        } else if (res["errorCode"] == 4) {
          message = "User cancelled payment";
        } else {
          message = "Payment failed";
        }
        setState(() {
          paymentResult = message;
        });
      },
      onError: (error) {
        setState(() {
          paymentResult = error.toString();
        });
      },
    );
  }

  // Xử lý khi nhấn thanh toán
  void _processPayment() async {
    try {
      // Lấy danh sách các sản phẩm đã chọn cho payload
      final itemsForPayload = _cartController.cartItems.value
          .where((item) => _selectedItems[item.cartItemId] == true)
          .map((item) => {
                'itemid': _getItemId(item),
                'itemname': item.name,
                'itemprice': item.price.toInt(),
                'itemquantity': 1
              })
          .toList();

      final selectedMethodId = _selectedPaymentMethodIdNotifier.value;
      print('Processing payment with method: $selectedMethodId');

      if (selectedMethodId == "zalopay") {
        // Phần còn lại không thay đổi
        final selectedItems = _cartController.cartItems.value
            .where((item) => _selectedItems[item.cartItemId] == true)
            .map((item) => {
                  'id': _getItemId(item),
                  'title': item.name,
                  'price': item.price,
                  'type': item.type,
                })
            .toList();

        // Chuyển đến trang xác nhận thanh toán
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              paymentMethod: selectedMethodId,
              amount: _finalAmount, // Truyền tham số với giá tiền đã giảm
              items: selectedItems,
              promoCode: _promoCode,
              discountpercent: _discountPercent,
              paymentType: "PRODUCT",
            ),
          ),
        );
      } else if (selectedMethodId == "momo") {
        _showSnackBar('Momo hiện tại đang bảo trì', Colors.red);
      } else if (selectedMethodId == "vnpay") {
        _showSnackBar('VNPay hiện tại đang bảo trì', Colors.red);
      } else if (selectedMethodId == "tms_wallet") {
        _showSnackBar('Ví TMS hiện tại đang bảo trì', Colors.red);
      } else {
        _showSnackBar('Vui lòng chọn phương thức thanh toán', Colors.red);
      }
    } catch (e) {
      print('Lỗi thanh toán: $e');
      _showSnackBar(
          'Đã xảy ra lỗi khi thanh toán: ${e.toString()}', Colors.red);
    }
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
                            if (_selectedComboDetail != null)
                              _buildComboDetailSection(),
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
          // Cách xử lý async
          _toggleItemSelection(item, !isSelected);
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
                  // Cách xử lý async
                  _toggleItemSelection(item, value);
                },
                activeColor: Colors.blue,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                              'Error loading image for item: ${item.name}, error: $error');
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(productTypeIcon,
                                color: Colors.grey[500], size: 40),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(productTypeIcon,
                            color: Colors.grey[500], size: 40),
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
                    if (item.discount != null && item.discount! > 0) ...[
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
        print('Unknown item type: $type');
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
        print('Unknown color for type: $type');
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
        print('Unknown icon for type: $type');
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourseScreen(),
                ),
              );
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
                          color: _promoApplied
                              ? Colors.grey.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: TextField(
                            enabled: !_promoApplied,
                            controller: TextEditingController(text: _promoCode),
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
                    _promoApplied
                        ? SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _cancelPromoCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          )
                        : SizedBox(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
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
                                  : const Text(
                                      'Áp dụng',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                            ),
                          ),
                  ],
                ),
                if (_promoApplied &&
                    _discountController.voucherDetails.value != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Giảm ${_discountPercent.toStringAsFixed(0)}% tổng giá trị đơn hàng',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_discountController.voucherDetails.value != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 26),
                            child: Text(
                              'Mã: ${_discountController.voucherDetails.value!.voucherCode}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 13,
                              ),
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
  void _applyPromoCode() async {
    setState(() {
      _isApplyingPromo = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);

      if (userId == null || userId.isEmpty) {
        throw Exception("Vui lòng đăng nhập để sử dụng mã giảm giá");
      }

      final userIdInt = int.parse(userId);
      final isValid =
          await _discountController.validateVoucher(_promoCode, userIdInt);

      if (!mounted) return;

      setState(() {
        _isApplyingPromo = false;

        if (isValid) {
          // Sử dụng giá trị discountValue từ response API
          _discountPercent = _discountController.discountValue.value;
          _promoApplied = true;

          // Hiển thị thông tin voucher cho người dùng
          final voucherDetails = _discountController.voucherDetails.value;
          String voucherInfo = '';
          if (voucherDetails != null) {
            final startDate = DateTime.parse(voucherDetails.startDate);
            final endDate = DateTime.parse(voucherDetails.endDate);
            final startDateFormatted =
                '${startDate.day}/${startDate.month}/${startDate.year}';
            final endDateFormatted =
                '${endDate.day}/${endDate.month}/${endDate.year}';

            voucherInfo =
                'Mã giảm giá ${voucherDetails.discountValue.toStringAsFixed(0)}% có hiệu lực từ $startDateFormatted đến $endDateFormatted';
          }

          _showSnackBar(
              voucherInfo.isNotEmpty
                  ? voucherInfo
                  : 'Áp dụng mã giảm giá thành công!',
              Colors.green);
        } else {
          _promoApplied = false;
          _discountPercent = 0;
          _showSnackBar(
              _discountController.errorMessage.value ??
                  'Mã giảm giá không hợp lệ hoặc đã hết hạn',
              Colors.red);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isApplyingPromo = false;
        _promoApplied = false;
        _discountPercent = 0;
        _showSnackBar('Lỗi: ${e.toString()}', Colors.red);
      });
    }
  }

  // Phương thức xử lý hủy áp dụng mã giảm giá
  void _cancelPromoCode() {
    setState(() {
      _promoApplied = false;
      _discountPercent = 0;
      _promoCode = '';
      _showSnackBar('Đã hủy áp dụng mã giảm giá', Colors.orange);
    });
  }

  // Widget hiển thị dòng thông tin đơn hàng
  Widget _buildOrderRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
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

  // Widget hiển thị phần combo gợi ý
  Widget _buildComboSuggestion() {
    // Lấy các khóa học đã chọn từ giỏ hàng
    final selectedCourseItems = _cartController.cartItems.value
        .where((item) =>
            _selectedItems[item.cartItemId] == true &&
            item.type.toUpperCase() == 'COURSE' &&
            item.courseId != null)
        .toList();

    if (selectedCourseItems.isEmpty) return const SizedBox.shrink();

    // Hiển thị thông tin khóa học được chọn
    final selectedCourse = selectedCourseItems.first;

    return ValueListenableBuilder<bool>(
      valueListenable: _cartController.isLoadingBundles,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<List<CourseBundle>>(
          valueListenable: _cartController.suggestedBundles,
          builder: (context, bundles, _) {
            if (isLoading) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                padding: const EdgeInsets.all(20),
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
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tìm kiếm combo phù hợp cho "${selectedCourse.name}"...',
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (bundles.isEmpty) return const SizedBox.shrink();

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
                  // Tiêu đề phần combo gợi ý
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.08),
                          Colors.purple.withOpacity(0.03)
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
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.card_giftcard,
                              color: Colors.purple, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Combo gợi ý cho bạn',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khóa học "${selectedCourse.name}" có trong combo này',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Tiết kiệm ${bundles.first.discount ?? 15}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chi tiết combo
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Image.network(
                                bundles.first.imageUrl ??
                                    'https://via.placeholder.com/60',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.card_giftcard,
                                      color: Colors.purple, size: 30);
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            bundles.first.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${bundles.first.courses.length} khóa học - Tiết kiệm ${bundles.first.discount ?? 15}%',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_formatCurrency(bundles.first.price)} đ',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _loadComboDetail(bundles.first.id),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.purple,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Xem chi tiết'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.purple.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.purple, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mua combo này để tiết kiệm chi phí và nhận thêm các khóa học liên quan!',
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
                                    fontSize: 13,
                                  ),
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
          },
        );
      },
    );
  }

  // Chuyển đến trang chi tiết combo
  // Phương thức lấy chi tiết combo
  Future<void> _loadComboDetail(int comboId) async {
    if (_isLoadingComboDetail) return;

    setState(() {
      _isLoadingComboDetail = true;
    });

    try {
      print('Đang tải chi tiết combo có ID: $comboId');
      final comboDetail = await _courseController.getComboDetail(comboId);

      setState(() {
        _selectedComboDetail = comboDetail;
        _isLoadingComboDetail = false;
      });

      if (comboDetail != null) {
        print(
            'Đã tải chi tiết combo: ${comboDetail.name} với ${comboDetail.courses.length} khóa học');
      } else {
        print('Không tìm thấy thông tin chi tiết cho combo ID: $comboId');
      }
    } catch (e) {
      print('Lỗi khi tải chi tiết combo: $e');
      setState(() {
        _isLoadingComboDetail = false;
      });
    }
  }

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
                              color:
                                  _getColorForType(item.type).withOpacity(0.1),
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

  // Phương thức xử lý khi người dùng chọn phương thức thanh toán
  void _selectPaymentMethod(String methodId) {
    print('Payment method selected: $methodId');
    print('Previous method: ${_selectedPaymentMethodIdNotifier.value}');

    // Update the ValueNotifier to trigger UI rebuild
    _selectedPaymentMethodIdNotifier.value = methodId;

    print('Updated payment method: ${_selectedPaymentMethodIdNotifier.value}');

    // Show feedback to user
    _showSnackBar(
        'Đã chọn phương thức thanh toán: ${_getSelectedPaymentMethod()}',
        Colors.green);
  }

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
          ValueListenableBuilder<String>(
            valueListenable: _selectedPaymentMethodIdNotifier,
            builder: (context, selectedMethodId, child) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  final isSelected = selectedMethodId == method.id;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: isSelected ? 2 : 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? method.color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _selectPaymentMethod(method.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                method.icon,
                                color: method.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Đã chọn',
                                        style: TextStyle(
                                          color: method.color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: method.id,
                              groupValue: selectedMethodId,
                              onChanged: (value) {
                                if (value != null) {
                                  _selectPaymentMethod(value);
                                }
                              },
                              activeColor: method.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Debug info - xác nhận phương thức thanh toán đã chọn
          // ValueListenableBuilder<String>(
          //   valueListenable: _selectedPaymentMethodIdNotifier,
          //   builder: (context, selectedMethodId, child) {
          //     return Padding(
          //       padding: const EdgeInsets.all(15),
          //       child: Container(
          //         padding: const EdgeInsets.all(10),
          //         decoration: BoxDecoration(
          //           color: Colors.grey.shade100,
          //           borderRadius: BorderRadius.circular(8),
          //           border: Border.all(color: Colors.grey.shade300),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Đã chọn: ${_getSelectedPaymentMethod()}',
          //               style: const TextStyle(
          //                 fontSize: 13,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             Text(
          //               'ID: $selectedMethodId',
          //               style: const TextStyle(
          //                 fontSize: 13,
          //                 color: Colors.red,
          //               ),
          //             ),
          //             const SizedBox(height: 8),
          //             ElevatedButton(
          //               onPressed: () {
          //                 final snackMessage = selectedMethodId.isEmpty
          //                     ? 'Chưa chọn phương thức thanh toán'
          //                     : 'Đã chọn phương thức: $selectedMethodId';
          //                 _showSnackBar(snackMessage, Colors.blue);
          //               },
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.blue,
          //                 minimumSize: const Size(double.infinity, 36),
          //                 padding: EdgeInsets.zero,
          //               ),
          //               child: const Text('Xác nhận phương thức thanh toán'),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  // Helper để lấy tên phương thức thanh toán đã chọn
  String _getSelectedPaymentMethod() {
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method.id == _selectedPaymentMethodIdNotifier.value,
      orElse: () => PaymentMethod(
        id: 'unknown',
        name: 'Chưa chọn',
        icon: Icons.help_outline,
        color: Colors.grey,
      ),
    );
    return selectedMethod.name;
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

  // Phương thức xử lý khi người dùng chọn/bỏ chọn một mục
  Future<void> _toggleItemSelection(CartItem item, bool isSelected) async {
    // Kiểm tra xung đột trước khi chọn
    if (isSelected) {
      bool hasConflict = _hasConflict(item, isSelected);

      if (hasConflict) {
        // Nếu có xung đột, hiển thị thông báo và không thực hiện thao tác
        if (item.type.toUpperCase() == 'COURSE') {
          _showSnackBar(
              'Không thể chọn khóa học này vì bạn đã chọn combo chứa khóa học này',
              Colors.orange);
        } else {
          _showSnackBar(
              'Không thể chọn combo này vì bạn đã chọn một hoặc nhiều khóa học trong combo này',
              Colors.orange);
        }
        return;
      }

      // Nếu đang chọn khóa học, kiểm tra xem có thuộc combo nào không
      if (item.type.toUpperCase() == 'COURSE' && item.courseId != null) {
        final availableCombos =
            await _findCombosContainingCourse(item.courseId!);

        if (availableCombos.isNotEmpty) {
          // Hiển thị dialog gợi ý chọn combo
          _showSuggestComboDialog(item, availableCombos);
          return; // Tạm dừng và không chọn khóa học cho đến khi người dùng quyết định
        }
      }

      // Nếu đang chọn combo, load thông tin chi tiết combo
      if (isSelected &&
          item.type.toUpperCase() == 'COMBO' &&
          item.courseBundleId != null) {
        print('Tải chi tiết combo ID: ${item.courseBundleId}');
        _loadComboDetail(item.courseBundleId!);
        // Xóa danh sách combo gợi ý
        _cartController.suggestedBundles.value = [];
      }
    }

    setState(() {
      _selectedItems[item.cartItemId] = isSelected;
      if (!isSelected &&
          item.type.toUpperCase() == 'COMBO' &&
          _selectedComboDetail != null &&
          _selectedComboDetail!.id == item.courseBundleId) {
        _selectedComboDetail = null;
      }
    });

    // Nếu là khóa học và được chọn, thì tải danh sách combo có chứa khóa học đó
    if (isSelected &&
        item.type.toUpperCase() == 'COURSE' &&
        item.courseId != null) {
      print('Tải gợi ý combo cho khóa học ID: ${item.courseId}');
      _cartController.loadCourseBundles(item.courseId!);
      // Xóa thông tin combo detail đang hiển thị để tránh xung đột
      setState(() {
        _selectedComboDetail = null;
      });
    }
    // Kiểm tra xem còn khóa học nào được chọn không
    else if (!isSelected && item.type.toUpperCase() == 'COURSE') {
      bool hasSelectedCourse = _cartController.cartItems.value
          .where((cartItem) =>
              _selectedItems[cartItem.cartItemId] == true &&
              cartItem.type.toUpperCase() == 'COURSE')
          .isNotEmpty;

      if (!hasSelectedCourse) {
        print('Không còn khóa học nào được chọn, xóa gợi ý combo');
        _cartController.suggestedBundles.value = [];
      }
    }
  }

  // Chuyển đến trang chi tiết combo
  void _navigateToComboDetail(int comboId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComboCourseScreen(comboId: comboId),
        ));
  }

  // Widget hiển thị chi tiết combo
  Widget _buildComboDetailSection() {
    if (_selectedComboDetail == null) return const SizedBox.shrink();

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
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phần chi tiết combo
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.08),
                  Colors.purple.withOpacity(0.03)
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
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book,
                      color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Khóa học trong "${_selectedComboDetail!.name}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_selectedComboDetail!.courses.length} khóa học',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chi tiết các khóa học trong combo
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedComboDetail!.courses.length,
            itemBuilder: (context, index) {
              final course = _selectedComboDetail!.courses[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book,
                            color: Colors.grey, size: 30),
                      );
                    },
                  ),
                ),
                title: Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCurrency(course.price)} đ',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            },
          ),

          // Nút xem chi tiết combo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _navigateToComboDetail(_selectedComboDetail!.id),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Xem trang chi tiết combo'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kiểm tra xem một khóa học có nằm trong một combo hay không
  bool _isCourseInBundle(int courseId, int bundleId) {
    if (_selectedComboDetail != null && _selectedComboDetail!.id == bundleId) {
      return _selectedComboDetail!.courses
          .any((course) => course.id == courseId);
    }
    return false;
  }

  // Lấy danh sách ID của các khóa học trong một combo
  List<int> _getCoursesInBundle(int bundleId) {
    if (_selectedComboDetail != null && _selectedComboDetail!.id == bundleId) {
      return _selectedComboDetail!.courses.map((course) => course.id).toList();
    }
    return [];
  }

  // Kiểm tra xem có xung đột giữa các mục đã chọn hay không
  bool _hasConflict(CartItem newItem, bool isSelected) {
    if (!isSelected) return false; // Nếu đang bỏ chọn thì không xung đột

    final List<CartItem> selectedItems = _cartController.cartItems.value
        .where((item) => _selectedItems[item.cartItemId] == true)
        .toList();

    // Nếu đang chọn khóa học, kiểm tra xem có combo nào chứa khóa học này đã được chọn chưa
    if (newItem.type.toUpperCase() == 'COURSE' && newItem.courseId != null) {
      for (final item in selectedItems) {
        if (item.type.toUpperCase() == 'COMBO' && item.courseBundleId != null) {
          if (_isCourseInBundle(newItem.courseId!, item.courseBundleId!)) {
            return true; // Xung đột: đã chọn combo chứa khóa học này
          }
        }
      }
    }

    // Nếu đang chọn combo, kiểm tra xem có khóa học nào trong combo này đã được chọn chưa
    if (newItem.type.toUpperCase() == 'COMBO' &&
        newItem.courseBundleId != null) {
      final courseIds = _getCoursesInBundle(newItem.courseBundleId!);
      for (final item in selectedItems) {
        if (item.type.toUpperCase() == 'COURSE' && item.courseId != null) {
          if (courseIds.contains(item.courseId)) {
            return true; // Xung đột: đã chọn khóa học có trong combo này
          }
        }
      }
    }
    return false;
  }

  // Kiểm tra xem một khóa học có thuộc bất kỳ combo nào trong giỏ hàng không
  Future<List<CartItem>> _findCombosContainingCourse(int courseId) async {
    List<CartItem> result = [];

    // Lấy tất cả combo trong giỏ hàng
    final combos = _cartController.cartItems.value
        .where((item) =>
            item.type.toUpperCase() == 'COMBO' && item.courseBundleId != null)
        .toList();

    for (var combo in combos) {
      if (combo.courseBundleId == null) continue;

      // Nếu combo này chưa được load chi tiết, tải thông tin
      if (_selectedComboDetail == null ||
          _selectedComboDetail!.id != combo.courseBundleId) {
        try {
          final comboDetail =
              await _courseController.getComboDetail(combo.courseBundleId!);
          if (comboDetail != null &&
              comboDetail.courses.any((course) => course.id == courseId)) {
            result.add(combo);
          }
        } catch (e) {
          print('Lỗi khi tải chi tiết combo để kiểm tra: $e');
        }
      } else if (_selectedComboDetail!.id == combo.courseBundleId) {
        // Nếu combo này đã được load, kiểm tra trực tiếp
        if (_selectedComboDetail!.courses
            .any((course) => course.id == courseId)) {
          result.add(combo);
        }
      }
    }

    return result;
  }

  // Hiển thị dialog gợi ý chọn combo thay vì khóa học riêng lẻ
  void _showSuggestComboDialog(
      CartItem courseItem, List<CartItem> availableCombos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Combo tiết kiệm hơn',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Lời khuyên',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Khóa học "${courseItem.name}" có trong các combo dưới đây. Chọn combo sẽ giúp bạn tiết kiệm hơn và nhận thêm các khóa học liên quan!',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableCombos.length,
                    itemBuilder: (context, index) {
                      final combo = availableCombos[index];
                      bool isComboSaving = courseItem.price > 0 &&
                          ((combo.price / courseItem.price) <
                              1.5); // Combo tiết kiệm nếu giá < 1.5 lần giá khóa học

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.purple.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.purple.withOpacity(0.05),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      combo.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isComboSaving)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Tiết kiệm',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Giá: ${_formatCurrency(combo.price)} đ',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Hiển thị thông tin so sánh
                                  if (combo.courseBundleId != null)
                                    FutureBuilder(
                                      future: _courseController.getComboDetail(
                                          combo.courseBundleId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          final comboDetail = snapshot.data!;
                                          final courseCount =
                                              comboDetail.courses.length;
                                          final savings =
                                              comboDetail.getSavings();

                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '$courseCount khóa học - Tiết kiệm ${_formatCurrency(savings)} đ',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                ],
                              ),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Center(
                                  child: combo.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: Image.network(
                                            combo.image,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.card_giftcard,
                                                  color: Colors.purple,
                                                  size: 30);
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.card_giftcard,
                                          color: Colors.purple, size: 30),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            const Divider(height: 1),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (combo.courseBundleId != null) {
                                        _navigateToComboDetail(
                                            combo.courseBundleId!);
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(
                                          color: Colors.purple),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                    child: const Text('Xem chi tiết'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Chọn combo này thay vì khóa học riêng lẻ
                                      setState(() {
                                        _selectedItems[courseItem.cartItemId] =
                                            false; // Bỏ chọn khóa học
                                        _selectedItems[combo.cartItemId] =
                                            true; // Chọn combo
                                      });
                                      // Tải chi tiết combo
                                      if (combo.courseBundleId != null) {
                                        _loadComboDetail(combo.courseBundleId!);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                    child: const Text('Chọn combo'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Vẫn chọn khóa học riêng lẻ theo ý người dùng
                setState(() {
                  _selectedItems[courseItem.cartItemId] = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                'Vẫn chọn khóa học này',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }
}
