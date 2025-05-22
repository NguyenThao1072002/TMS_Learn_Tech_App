import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/presentation/controller/cart_controller.dart';
import 'package:tms_app/presentation/controller/login/login_controller.dart';
import 'package:tms_app/presentation/controller/payment_controller.dart';
import 'package:tms_app/domain/usecases/payment_usecase.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentMethod;
  final double amount;
  final List<Map<String, dynamic>> items;
  final String promoCode;
  final double discountpercent;
  final String paymentType;

  const PaymentScreen(
      {Key? key,
      required this.paymentMethod,
      required this.amount,
      required this.items,
      required this.promoCode,
      required this.discountpercent,
      required this.paymentType})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final PaymentController _paymentController;
  static const EventChannel eventChannel =
      EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform =
      MethodChannel('flutter.native/channelPayOrder');

  String email = "";
  String paymentResult = "";
  bool _isProcessing = true;
  bool _isCompleted = false;
  bool _isFailed = false;

  String _transactionId = '';
  Timer? _timer;
  int _secondsRemaining = 300;
  int returncode = 0;
  String returnmessage = '';
  bool _shouldShowRetry = false;

  final PaymentUseCase _paymentUseCase = GetIt.instance<PaymentUseCase>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _paymentController = PaymentController(paymentUseCase: _paymentUseCase);
    _animationController.forward();

    // Generate transaction ID
    _transactionId =
        'TMS${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Start countdown timer
    _startTimer();

    // Process payment based on selected method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        if (!_isCompleted && !_isFailed) {
          setState(() {
            _isFailed = true;
            _isProcessing = false;
            _shouldShowRetry = true;
            returnmessage = "Hết thời gian xử lý. Vui lòng thử lại.";
          });
        }
      }
    });
  }

  void _processPayment() {
    if (widget.paymentMethod == 'zalopay') {
      _processPaymentZaloPay();
    } else if (widget.paymentMethod == 'momo') {
      _showPaymentUnavailable("Ví MoMo hiện tại đang bảo trì");
    } else if (widget.paymentMethod == 'vnpay') {
      _showPaymentUnavailable("VNPay hiện tại đang bảo trì");
    } else if (widget.paymentMethod == 'tms_wallet') {
      _showPaymentUnavailable("Ví TMS hiện tại đang bảo trì");
    } else {
      _showPaymentUnavailable("Phương thức thanh toán không hợp lệ");
    }
  }

  void _showPaymentUnavailable(String message) {
    setState(() {
      _isProcessing = false;
      _isFailed = true;
      returnmessage = message;
      _shouldShowRetry = false;
    });
  }

  void _onEvent(dynamic event) {
    var res = Map<String, dynamic>.from(event);
    setState(() {
      if (res["errorCode"] == 1) {
        _isCompleted = true;
        _isFailed = false;
        _isProcessing = false;
        paymentResult = "Thanh toán thành công";
      } else if (res["errorCode"] == 4) {
        _isCompleted = false;
        _isFailed = true;
        _isProcessing = false;
        paymentResult = "Người dùng đã hủy thanh toán";
      } else {
        _isCompleted = false;
        _isFailed = true;
        _isProcessing = false;
        paymentResult = "Giao dịch thất bại";
      }
    });
  }

  void _onError(Object error) {
    setState(() {
      _isCompleted = false;
      _isFailed = true;
      _isProcessing = false;
      _shouldShowRetry = true;
      returnmessage = "Giao dịch thất bại: $error";
    });
  }

  Future<Map<String, dynamic>> _payWithZaloPay(String zpToken) async {
    try {
      final result =
          await platform.invokeMethod('payOrder', {'zptoken': zpToken});
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

  Future<void> _processPaymentZaloPay() async {
    try {
      setState(() {
        _isProcessing = true;
        _isFailed = false;
        _isCompleted = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(LoginController.KEY_SAVED_EMAIL) ?? "";

      // Create payload for ZaloPay
      final paymentRequest = {
        'appUser': savedEmail,
        'amount': widget.amount.toInt(),
        'description': 'Payment $savedEmail',
        'bankCode': 'zalopayapp',
        'items': widget.items.isNotEmpty ? widget.items : null,
        'embedData': {
          'promotion_code':
              widget.promoCode.isNotEmpty ? widget.promoCode : 'NONE',
          'merchant_info': 'TMS Learning',
          'redirecturl': 'https://tms.com/payment-result'
        }
      };

      // Get ZaloPay token
      final tokenResponse =
          await _paymentController.getZaloPayToken(paymentRequest);

      // Extract ZaloPay token
      String zpToken = '';
      if (tokenResponse.containsKey('zp_trans_token')) {
        zpToken = tokenResponse['zp_trans_token']?.toString() ?? '';
      } else if (tokenResponse.containsKey('zptoken')) {
        zpToken = tokenResponse['zptoken']?.toString() ?? '';
      } else {
        // Fallback to search for token in any field
        for (var entry in tokenResponse.entries) {
          if (entry.value is String &&
              entry.value.toString().isNotEmpty &&
              (entry.key.toLowerCase().contains('token') ||
                  entry.value.toString().length > 20)) {
            zpToken = entry.value.toString();
            break;
          }
        }
      }

      if (zpToken.isEmpty) {
        throw Exception("Không thể lấy được token thanh toán");
      }

      // Process payment with ZaloPay
      final result = await _payWithZaloPay(zpToken);

      if (result['status'] == 'success') {
        // Check payment status
        final checkStatus =
            await _paymentController.getQueryPayment(result['appTransID']);

        if (checkStatus["returncode"] == 1) {
          // Success
          setState(() {
            _isProcessing = false;
            _isCompleted = true;
            _isFailed = false;
            _transactionId = checkStatus["apptransid"] ?? result['appTransID'];
            returncode = checkStatus["returncode"];
            returnmessage =
                checkStatus["returnmessage"] ?? "Thanh toán thành công";
          });

          // Save payment details to backend after successful payment
          await _savePaymentToBackend();
        } else {
          // Failed
          setState(() {
            _isProcessing = false;
            _isCompleted = false;
            _isFailed = true;
            _shouldShowRetry = true;
            returncode = checkStatus["returncode"];
            returnmessage =
                checkStatus["returnmessage"] ?? "Thanh toán thất bại";
          });
        }
      } else {
        // Failed
        setState(() {
          _isProcessing = false;
          _isCompleted = false;
          _isFailed = true;
          _shouldShowRetry = true;
          returnmessage = result['message'] ?? "Thanh toán thất bại";
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isCompleted = false;
        _isFailed = true;
        _shouldShowRetry = true;
        returnmessage = "Lỗi thanh toán: $e";
      });
    }
  }

  // Method to save payment details to backend
  Future<void> _savePaymentToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);

      if (userId == null || userId.isEmpty) {
        print("Error: No user ID found");
        return;
      }

      // Chuyển đổi userId từ String sang int
      final int userIdInt;
      try {
        userIdInt = int.parse(userId);
      } catch (e) {
        print("Error: Invalid user ID format - $userId");
        return;
      }
      List<PaymentDetailModel> paymentDetails = [];
      double subtotal = 0.0;
      double discountValue = 0.0;
      double discountPercent = 0.0;
      if (widget.paymentType == "PRODUCT") {
        // Create payment details array
        paymentDetails = widget.items.map((item) {
          return PaymentDetailModel(
              courseId: item['type'].toString().toUpperCase() == 'COURSE'
                  ? int.parse(item['id'].toString())
                  : null,
              testId: item['type'].toString().toUpperCase() == 'EXAM'
                  ? int.parse(item['id'].toString())
                  : null,
              courseBundleId: item['type'].toString().toUpperCase() == 'COMBO'
                  ? int.parse(item['id'].toString())
                  : null,
              price: double.parse(item['price'].toString()),
              type: item['type'].toString().toUpperCase());
        }).toList();

        // Calculate discount
        subtotal = widget.items.fold(
            0, (sum, item) => sum + double.parse(item['price'].toString()));
        discountValue = subtotal - widget.amount;
        discountPercent =
            widget.discountpercent > 0.0 ? widget.discountpercent : 0.0;
      }

      // Create payment payload
      final PaymentRequestModel paymentRequest = PaymentRequestModel(
          paymentDate: DateTime.now().toIso8601String(),
          subTotalPayment: subtotal,
          totalPayment: widget.amount,
          totalDiscount: discountValue,
          discountValue: discountPercent.round(),
          paymentMethod: widget.paymentMethod,
          transactionId: _transactionId,
          accountId: userIdInt,
          paymentType: widget.paymentType,
          status: "COMPLETED",
          note: "Thanh toán thành công qua ZaloPay",
          paymentDetails: paymentDetails,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String());

      // Send request to backend using the controller
      final response =
          await _paymentController.savePaymentRecord(paymentRequest);
      print("Payment saved successfully: ${response.data.id}");
    } catch (e) {
      print("Error saving payment: $e");
    }
  }

  void _handleRetry() {
    setState(() {
      _secondsRemaining = 300; // Reset timer
      _isProcessing = true;
      _isFailed = false;
    });
    _processPayment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _showCancelConfirmation(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPaymentHeaderSection(),
              const SizedBox(height: 20),
              _isProcessing
                  ? _buildProcessingSection()
                  : _isCompleted
                      ? _buildCompletedSection()
                      : _buildFailedSection(),
              const SizedBox(height: 20),
              _buildOrderDetailsSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text('Bạn có chắc muốn hủy quá trình thanh toán này?'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Có'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHeaderSection() {
    // Define payment method details
    final methodDetails = _getPaymentMethodDetails();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            methodDetails.color.withOpacity(0.7),
            methodDetails.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Payment method icon
          _buildMethodIcon(methodDetails),
          const SizedBox(height: 15),
          // Payment method name
          Text(
            methodDetails.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Payment method description
          Text(
            methodDetails.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          // Transaction ID
          Text(
            'Mã giao dịch: $_transactionId',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 25),
          // Amount
          Text(
            '${_formatCurrency(widget.amount)} đ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMethodIcon(PaymentMethodDetails details) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        details.icon,
        size: 40,
        color: details.color,
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Đang xử lý thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Vui lòng không tắt ứng dụng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 25),

          // Countdown timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hết hạn sau: ${_formatTime(_secondsRemaining)}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 60,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Thanh toán thành công',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Giao dịch đã được xử lý thành công',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 20),
          _buildInfoRow('Thời gian:',
              DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
          const SizedBox(height: 10),
          _buildInfoRow('Mã giao dịch:', _transactionId),
          if (_isCompleted) ...[
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Các khóa học đã mua sẽ được kích hoạt trong tài khoản của bạn.',
                      style: TextStyle(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFailedSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error,
              color: Colors.red.shade600,
              size: 60,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Thanh toán thất bại',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            returnmessage,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Lỗi thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _shouldShowRetry
                      ? 'Vui lòng kiểm tra số dư tài khoản hoặc thử lại sau.'
                      : 'Phương thức thanh toán này hiện không khả dụng.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),

          // List of items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _getItemTypeDisplay(item['type']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  '${_formatCurrency(item['price'])} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getItemTypeColor(item['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getItemTypeIcon(item['type']),
                    color: _getItemTypeColor(item['type']),
                    size: 22,
                  ),
                ),
              );
            },
          ),

          // Total amount
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_formatCurrency(widget.amount)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_isProcessing) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showCancelConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hủy thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Return to previous screen
              Navigator.pop(context); // Return to cart screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hoàn tất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      // Failed state
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Return to previous screen
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (_shouldShowRetry) ...[
              const SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
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
    );
  }

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  PaymentMethodDetails _getPaymentMethodDetails() {
    switch (widget.paymentMethod) {
      case 'tms_wallet':
        return PaymentMethodDetails(
          name: 'Ví TMS',
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
          description: 'Thanh toán bằng số dư Ví TMS',
        );
      case 'momo':
        return PaymentMethodDetails(
          name: 'Ví MoMo',
          icon: Icons.wallet,
          color: Colors.pink,
          description: 'Thanh toán qua ứng dụng MoMo',
        );
      case 'zalopay':
        return PaymentMethodDetails(
          name: 'ZaloPay',
          icon: Icons.wallet,
          color: Colors.blue.shade700,
          description: 'Thanh toán qua ứng dụng ZaloPay',
        );
      case 'vnpay':
        return PaymentMethodDetails(
          name: 'VN Pay',
          icon: Icons.payment,
          color: Colors.red,
          description: 'Thanh toán qua VNPay',
        );
      default:
        return PaymentMethodDetails(
          name: 'Phương thức thanh toán',
          icon: Icons.payment,
          color: Colors.blue,
          description: 'Thanh toán đơn hàng',
        );
    }
  }

  String _getItemTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'course':
        return 'Khóa học';
      case 'exam':
        return 'Đề thi';
      case 'combo':
        return 'Combo khóa học';
      default:
        return type;
    }
  }

  Color _getItemTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'course':
        return Colors.blue;
      case 'exam':
        return Colors.orange;
      case 'combo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'course':
        return Icons.book;
      case 'exam':
        return Icons.quiz;
      case 'combo':
        return Icons.card_giftcard;
      default:
        return Icons.shopping_bag;
    }
  }
}

class PaymentMethodDetails {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  PaymentMethodDetails({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}
