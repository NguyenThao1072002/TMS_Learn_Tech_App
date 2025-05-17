import 'package:flutter/material.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/presentation/widgets/component/bottom_wave_clipper.dart';
import 'package:tms_app/presentation/screens/login/verify_otp_screen.dart';
import 'package:tms_app/core/utils/toast_helper.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final ForgotPasswordController controller;

  const VerifyEmailScreen({
    Key? key,
    required this.email,
    required this.controller,
  }) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo email từ tham số nếu có
    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    }
  }

  // Kiểm tra định dạng email hợp lệ
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return emailRegex.hasMatch(email);
  }

  // Xử lý gửi OTP khi người dùng nhấn nút
  Future<void> _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 50));

      try {
        final email = _emailController.text.trim();
        final result = await widget.controller.sendOtpToEmail(email);

        if (result) {
          // Chuyển đến màn hình xác thực OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                email: email,
                controller: widget.controller,
              ),
            ),
          );

          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          ToastHelper.showErrorToast('Không thể gửi OTP, vui lòng thử lại!');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ToastHelper.showErrorToast(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quên mật khẩu",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền với hiệu ứng sóng
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: 150,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tiêu đề và hướng dẫn
                            const Text(
                              'Tìm tài khoản',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Chúng tôi sẽ gửi mã OTP xác thực qua email của bạn.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 60),

                            // Ô nhập email
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nhập email của bạn!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: _emailController,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        hintText: 'VD: example@email.com',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        alignLabelWithHint: true,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Email không được để trống!";
                                        }
                                        if (!isValidEmail(value)) {
                                          return "Email không hợp lệ! Vui lòng nhập đúng định dạng.";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Nút gửi mã
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed:
                                          _isLoading ? null : _handleSendOtp,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : const Text(
                                              'Gửi mã',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
