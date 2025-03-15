import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String emailOrPhone;
  const VerifyOtpScreen({Key? key, required this.emailOrPhone})
      : super(key: key);
  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool isButtonEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text('Mã xác thực',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 8),
            const Text('Vui lòng nhập mã để xác thực tài khoản',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),
            Text("Mã đã được gửi đến: ${widget.emailOrPhone}",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
            const SizedBox(height: 24),

            //ô nhập mã OTP
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: otpController,
              keyboardType: TextInputType.number,
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 50,
                activeColor: Colors.white,
                selectedColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
              onChanged: (value) {
                setState(() {
                  isButtonEnabled = value.length == 4; //chỉ bật nút khi đủ 4 số
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Bạn không nhận được mã?",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            //nút gửi lại mã
            TextButton(
                onPressed: () {
                  print("Gửi lại mã OTP...");
                  //todo: gửi lại OTP qua API
                },
                child: const Text("Gửi lại",
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)
                ),
                ),
                const SizedBox(height: 24),
                //thanh tiến trình(fake)
                LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                const Text("1 of 2", 
                style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 32),

                //nút xác minh OTP
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: isButtonEnabled ? (){
                    print("Xác minh OTP: ${otpController.text}");
                    //todo: gọi API xác thực OTP
                  }
                  :null, //nếu chưa đủ 4 số thì disable
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  child: const Text('Xác thực', style: TextStyle(fontSize: 18,  color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                )
          ],
        ),
      ),
    );
  }
}
