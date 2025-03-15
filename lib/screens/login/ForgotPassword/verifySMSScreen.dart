import 'package:flutter/material.dart';
import '../../../widgets/vertifyPassword/bottomWaveClipper.dart';

class VerifySMSScreen extends StatelessWidget {
  final TextEditingController _smsControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^(?:\+84|0)([35789])[0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }
//   (?:\+84|0): Bắt đầu bằng +84 (mã quốc gia VN) hoặc 0.
// ([35789]): Số tiếp theo phải thuộc các đầu số phổ biến của VN (3, 5, 7, 8, 9).
// [0-9]{8}$: Tiếp theo phải là 8 chữ số (0-9), kết thúc chuỗi.

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
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: false,
        ),
        body: Stack( //bọc stack để làm hiệu ứng cong nền
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
                      'Chúng tôi sẽ gửi mã OTP xác thựa qua SĐT của bạn.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nhập số điện thoại của bạn!',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _smsControler,
                          decoration: InputDecoration(
                            hintText: 'VD: 0348740942',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Số điện thoại không được để trống!";
                            }
                            if (!isValidPhoneNumber(value)) {
                              return "Số điện thoại không hợp lệ! Vui lòng nhập đúng định dạng.";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate())
                            print("Gửi mã OTP đến SĐT: ${_smsControler.text}");
                          //chuyển đén MH nhập mã OTP
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
          ],
        ),
        
        );
  }
}
