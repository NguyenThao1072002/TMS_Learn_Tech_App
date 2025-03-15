import 'package:flutter/material.dart';
import 'package:tms/screens/login/ForgotPassword/verifyOTPScreen.dart';
import '../../../services/AccountServices.dart';
import '../../../widgets/vertifyPassword/bottomWaveClipper.dart';

class VerifyEmailScreen extends StatelessWidget {
  final TextEditingController _emailControler = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return emailRegex.hasMatch(email);
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
            onPressed: () => Navigator.pop(context), //pop để quay lại mh trc đó
          ),
          title: const Text(
            "Quên mật khẩu",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: false,
        ),
        body: Stack(//bọc stack để làm hiệu ứng cong nền
            children: [
          //hiệu ứng
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: 120,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Text('Tìm tài khoản',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 12),
                    const Text(
                      'Chúng tôi sẽ gửi mã OTP xác thựa qua Email của bạn.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nhập email của bạn!',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailControler,
                          decoration: InputDecoration(
                            hintText: 'VD: ABC@gmail.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email không được để trống!";
                            }
                            if (!isValidEmail(value)) {
                              return "Email không hợp lệ! Vui lòng nhập đúng định dạng!";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                       onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String email = _emailControler.text.trim();

                            // Gọi API để gửi mã OTP
                            bool otpSent =
                                await AccountServices.sendOtpToEmail(email);

                            if (otpSent) {
                              // Chuyển đến màn hình nhập mã OTP và truyền email
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VerifyOtpScreen(emailOrPhone: _emailControler.text),
                                ),
                              );
                            } else {
                              // Hiển thị thông báo lỗi nếu gửi OTP thất bại
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Không thể gửi mã OTP. Vui lòng thử lại!")),
                              );
                            }
                          }
                        },

                        child: const Text('Gửi mã',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )),
          )
        ]));
  }
}
