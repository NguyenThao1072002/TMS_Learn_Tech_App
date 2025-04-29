import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivateCourseScreen extends StatefulWidget {
  const ActivateCourseScreen({Key? key}) : super(key: key);

  @override
  State<ActivateCourseScreen> createState() => _ActivateCourseScreenState();
}

class _ActivateCourseScreenState extends State<ActivateCourseScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _activationCodeController =
      TextEditingController();
  final FocusNode _activationCodeFocus = FocusNode();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Theme colors
  final Color primaryColor = const Color(0xFF3498DB); // Primary blue
  final Color lightBlueColor = const Color(0xFFE1F5FE); // Light blue background
  final Color accentColor = const Color(0xFF2980B9); // Darker blue for accents

  // Sample activation codes (in a real app, these would be validated against a backend)
  final List<String> _validCodes = ['LEARN2023', 'TMS12345', 'EDUCODE78'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _activationCodeController.dispose();
    _activationCodeFocus.dispose();
    super.dispose();
  }

  // Validate and activate the course
  void _activateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _activationCodeController.text.trim().toUpperCase();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;

      if (_validCodes.contains(code)) {
        _isSuccess = true;
      } else {
        _errorMessage = 'Mã kích hoạt không hợp lệ hoặc đã được sử dụng';
      }
    });

    if (_isSuccess) {
      _showSuccessDialog();
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 24,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon và hiệu ứng
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'KÍCH HOẠT THÀNH CÔNG',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(color: Colors.grey.withOpacity(0.2), height: 1),
              // Nội dung
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        children: [
                          const TextSpan(
                              text:
                                  'Bạn đã kích hoạt thành công khóa học với mã '),
                          TextSpan(
                            text:
                                '"${_activationCodeController.text.trim().toUpperCase()}"',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Khóa học đã được thêm vào danh sách "Khóa học của tôi".',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
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
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Quay về màn hình trước
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Vào học ngay',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset form
                    setState(() {
                      _activationCodeController.clear();
                      _isSuccess = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Kích hoạt mã khác',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kích hoạt khóa học',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                lightBlueColor.withOpacity(0.3),
                lightBlueColor.withOpacity(0.5),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header illustration
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Replace with an actual image in a real app
                            Icon(
                              Icons.school,
                              size: 120,
                              color: primaryColor.withOpacity(0.2),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.vpn_key,
                                    size: 60,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Kích hoạt khóa học mới',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Instruction text
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Hướng dẫn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nhập mã kích hoạt khóa học bạn nhận được từ email hoặc từ thẻ cào kích hoạt. Mã kích hoạt thường bao gồm chữ và số, không phân biệt chữ hoa, chữ thường.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Activation form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mã kích hoạt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _activationCodeController,
                              focusNode: _activationCodeFocus,
                              autofocus: true,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: primaryColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập mã kích hoạt',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[400],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      _activationCodeController.clear(),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập mã kích hoạt';
                                }
                                // Add additional validation if needed
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                                LengthLimitingTextInputFormatter(12),
                              ],
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Spacer để đẩy nút xuống dưới
                      const Spacer(),

                      // Divider để tách khu vực nhập mã và nút kích hoạt
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: primaryColor.withOpacity(0.2),
                          thickness: 1,
                        ),
                      ),

                      // Activate button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _activateCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Kích hoạt',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Need help text
                      TextButton.icon(
                        onPressed: () {
                          // Show help dialog or navigate to help page
                        },
                        icon: Icon(Icons.help_outline,
                            size: 16, color: primaryColor),
                        label: Text(
                          'Cần trợ giúp với mã kích hoạt?',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
