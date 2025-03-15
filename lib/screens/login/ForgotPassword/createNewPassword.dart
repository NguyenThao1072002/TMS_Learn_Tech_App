import 'package:flutter/material.dart';
import 'package:tms/screens/Login/login.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  @override
  _CreateNewPasswordScreenState createState() =>
      _CreateNewPasswordScreenState();
}

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // Cho phép chạm ra ngoài để đóng
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          // Khi chạm vào bất kỳ đâu trên màn hình, đóng popup và chuyển về trang đăng nhập
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: Scaffold(
          backgroundColor:
              Colors.black.withOpacity(0.5), // Làm tối nền phía sau popup
          body: Center(
            child: GestureDetector(
              onTap: () {
                // Khi chạm vào ảnh, cũng sẽ đóng popup và chuyển trang đăng nhập
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Image.asset(
                "assets/images/resetPasswordSuccess.png",
                height: 450, 
              ),
            ),
          ),
        ),
      );
    },
  );
}


class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;
  bool _isConfirmFieldEnable = false; //chỉ bạt khi nhập hợp lệ ô mk mới

  //kiểm tra mật khẩu có hợp lệ không:  Ít nhất 1 chữ hoa, 1 chữ thường,  1 chữ số.  Tối thiểu 8 ký tự
  bool isValidPassword(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  //kiểm tra 2 mk có khớp với nhau không, khi nhập mk mới dktra dkien hợp lệ
  void _validatePassword() {
    setState(() {
      _isConfirmFieldEnable = isValidPassword(_newPasswordController.text);
      //_confirmPasswordController.clear();
      _isButtonEnabled = false;
    });
  }

//kiểm tra trùng khi xác nhận mk
  void _validateConfirmPassword() {
    setState(() {
      _isButtonEnabled = _isConfirmFieldEnable &&
          _confirmPasswordController.text == _newPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text(
          "Quên mật khẩu",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          onChanged: _validatePassword, //KIỂM TRA MK MỖI KHJI NHẬP
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tạo mật khẩu mới',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                  "Lưu ý: Mật khẩu phải có ít nhát 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt ",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),

              //o nhập mk mới
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Nhập mật khẩu mới",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (_) => _validatePassword(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Mật khẩu không được để trống!";
                  }
                  if (!isValidPassword(value)) {
                    return "Mật khẩu phải có ít nhát 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //ô xác nhận mật khẩu ( chỉ bật nếu mk mới hợp lệ)
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                enabled: _isConfirmFieldEnable, // Chỉ bật khi mật khẩu hợp lệ
                decoration: InputDecoration(
                  hintText: "Xác nhận mật khẩu",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isButtonEnabled = _isConfirmFieldEnable &&
                        value == _newPasswordController.text;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Vui lòng nhập mật khẩu xác nhận!";
                  }
                  if (value != _newPasswordController.text) {
                    return "Mật khẩu không khớp!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              //check box hiển thị mật khẩu
              Row(
                children: [
                  Checkbox(
                      value: _isPasswordVisible,
                      onChanged: (value) {
                        setState(() {
                          _isPasswordVisible = value!;
                        });
                      }),
                  const Text("Hiện mật khẩu"),
                ],
              ),
              const SizedBox(height: 24),
              // thanh tiến trình fake
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              const Text("2 of 2",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 32),

              //Nút xác nhận mật khẩu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          print(
                              "Mật khẩu mới : ${_newPasswordController.text}");
                          //todo: gọi api cập nhật mk
                          // Hiển thị popup thông báo thành công
                          _showSuccessDialog(context);
                          // //chuyển qua mh đăng nhập thành công
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             PasswordUpdateSuccessScreen()));
                        }
                      : null, //th chưa nhập đử or k klhowps thì disable
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
