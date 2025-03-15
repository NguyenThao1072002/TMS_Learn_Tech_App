import 'package:flutter/material.dart';
import 'package:tms/screens/login/ForgotPassword/verifyEmailScreen.dart';
import 'package:tms/screens/login/ForgotPassword/verifySMSScreen.dart';
import '../../../services/AccountServices.dart';
//import '../login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  //const ForgotPasswordScreen({super.key});
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _selectedMethod = "email"; //mặc định chọn email
  String? _userEmail;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // hàm lấy dữ liệu từ trang login
  }

//hàm lấy ttin từ bước đăng nhập
  Future<void> _fetchUserData() async {
    final userData = await AccountServices.getUserData();
    setState(() {
      _userEmail = userData['email'];
      _userPhone = userData['phone'];
    });
  }

//hàm ẩn bớt thông tin email & SDT
  String _maskEmail(String email) {
    List<String> parts = email.split('@');
    if (parts.length != 2) return email;
    String domain = parts[1];
    String hiddenPart = '*' * (parts[0].length - 2);
    return '${parts[0].substring(0, 2)}$hiddenPart@$domain';
  }

  String _maskPhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 2)}${'*' * (phone.length - 4)}${phone.substring(phone.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Quên mật khẩu",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Image.asset('assets/images/login/forgotPassword.png', height: 200),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng chọn phương thức xác minh!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 48),
            //chọn phương thức nhận mã xác minh
            GestureDetector(
              onTap: () {
                setState(() => _selectedMethod = 'email');
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: _selectedMethod == 'email'
                          ? Colors.lightBlue
                          : Colors.black54,
                      width: 2),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Màu đổ bóng
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(2, 4), // Đổ bóng hướng xuống
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 36),
                    const SizedBox(width: 0),
                    Expanded(
                        child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text(
                            'via EMAIL',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _userEmail != null ? _maskEmail(_userEmail!) : " ",
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis, // Cắt nếu quá dài
                          )
                        ])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() => _selectedMethod = 'sms');
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: _selectedMethod == 'sms'
                          ? Colors.lightBlue
                          : Colors.black54,
                      width: 2),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Màu đổ bóng
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(2, 4), // Đổ bóng hướng xuống
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sms, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'via SMS',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _userPhone != null ? _maskPhone(_userPhone!) : " ",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 42),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      //xly đièu hướng qua mh nhập OTP
                      print('Chọn phương thức: $_selectedMethod');
                      if (_selectedMethod == 'sms') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifySMSScreen()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyEmailScreen()));
                      }
                    },
                    child: const Text(
                      'Tiếp',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ))),
          ],
        ),
      ),
    );
  }
}
