import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tms_app/presentation/controller/register_controller.dart';
import 'package:tms_app/presentation/widgets/component/bottom_wave_clipper.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'dart:async';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final RegisterController controller;

  const RegisterOtpScreen({
    Key? key,
    required this.email,
    required this.controller,
  }) : super(key: key);

  @override
  _RegisterOtpScreenState createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // Timer variables
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  bool _isOtpExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 300;
    _isOtpExpired = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isOtpExpired = true;
          _timer?.cancel();
          ToastHelper.showInfoToast(
              'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.');
        }
      });
    });
  }

  String get _timerText {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 4) return;

    if (_isOtpExpired) {
      ToastHelper.showErrorToast('Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await widget.controller.verifyOtp(
        _otpController.text,
        widget.email,
      );

      if (result['success']) {
        // Show success toast
        ToastHelper.showSuccessToast(result['message']);
        // Navigate to login page on success
        widget.controller.navigateToLogin(context);
      } else {
        // Show error toast
        ToastHelper.showErrorToast(result['message']);
      }
    } catch (e) {
      ToastHelper.showErrorToast(e.toString());
    } finally {
      setState(() => _isLoading = false);
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
                      'Xác thực tài khoản',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mã OTP đã được gửi đến ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mã có hiệu lực trong: $_timerText',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds < 60
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ],
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
                              if (value.length == 4) {
                                _verifyOtp();
                              }
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
                            onPressed: (_isLoading ||
                                    !_isOtpExpired &&
                                        _remainingSeconds >
                                            240) // Disable for first 60 seconds
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    try {
                                      final success = await widget.controller
                                          .sendOtpToEmail(widget.email);
                                      if (success) {
                                        ToastHelper.showSuccessToast(
                                            'Đã gửi lại mã OTP!');
                                        _startTimer(); // Restart timer on successful resend
                                      } else {
                                        ToastHelper.showErrorToast(
                                            'Không thể gửi lại mã OTP. Vui lòng thử lại sau.');
                                      }
                                    } catch (e) {
                                      ToastHelper.showErrorToast(
                                          'Lỗi: ${e.toString()}');
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                            child: Text(
                              'Gửi lại mã${!_isOtpExpired && _remainingSeconds > 240 ? ' (${((_remainingSeconds - 240) / 60).ceil()} phút)' : ''}',
                              style: TextStyle(
                                color: (_isLoading ||
                                        !_isOtpExpired &&
                                            _remainingSeconds > 240)
                                    ? Colors.grey
                                    : Colors.blue,
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
