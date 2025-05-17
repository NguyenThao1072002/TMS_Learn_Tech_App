import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/presentation/widgets/component/bottom_wave_clipper.dart';
import 'package:tms_app/presentation/screens/login/reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email; // Có thể là email hoặc số điện thoại
  final ForgotPasswordController controller;
  final bool isPhoneNumber;

  const VerifyOtpScreen({
    Key? key,
    required this.email, // Giữ tên tham số là email để khỏi sửa quá nhiều code
    required this.controller,
    this.isPhoneNumber = false, // Mặc định là xác thực qua email
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 4) return;

    setState(() => _isLoading = true);

    try {
      print("Đang xác thực OTP: ${_otpController.text}");

      final result = await widget.controller.verifyOtp(
        _otpController.text,
        widget.email,
      );

      setState(() => _isLoading = false);

      print("Kết quả xác thực OTP: $result");

      if (result) {
        print("OTP đúng, chuyển tới màn hình đặt lại mật khẩu");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              otp: _otpController.text,
            ),
          ),
        );
      } else {
        print("OTP không đúng, hiển thị thông báo lỗi");
        ToastHelper.showErrorToast(
            'Mã OTP không chính xác. Vui lòng kiểm tra lại!');
      }
    } catch (e) {
      print("Lỗi khi xác thực OTP: $e");
      setState(() => _isLoading = false);
      // Sử dụng ToastHelper thay vì Get.snackbar
      ToastHelper.showErrorToast(
          'Đã xảy ra lỗi khi xác thực OTP. Vui lòng thử lại sau.');
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
          'Xác thực OTP',
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
          // Wave effect background
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Nhập mã OTP',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isPhoneNumber
                          ? 'Mã OTP đã được gửi đến SĐT ${widget.email}'
                          : 'Mã OTP đã được gửi đến ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 50,
                              fieldWidth: 50,
                              activeColor: Colors.blue,
                              selectedColor: Colors.blue,
                              inactiveColor: Colors.grey,
                            ),
                            onChanged: (value) {
                              // Không tự động xác thực khi nhập đủ 4 số
                              // Người dùng phải nhấn nút Xác thực
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading ? null : _verifyOtp,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Xác thực',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    try {
                                      await widget.controller
                                          .sendOtpToEmail(widget.email);
                                      ToastHelper.showSuccessToast(
                                          'Đã gửi lại mã OTP');
                                    } catch (e) {
                                      ToastHelper.showErrorToast(e.toString());
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                            child: const Text(
                              'Gửi lại mã',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
