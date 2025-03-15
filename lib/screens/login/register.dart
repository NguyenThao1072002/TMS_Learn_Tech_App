import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tms/screens/Login/login.dart';
import '../../services/AccountServices.dart';
import '../../utils/shared_prefs.dart';
import '../homePage/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedCountryCode = '+84';
  bool _loading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final response = await AccountServices.register(
      _nameController.text,
      _emailController.text,
      _birthdayController.text,
      //  _phoneController.text,
      // _passwordController.text,
    );

    setState(() => _loading = false);

    if (response != null) {
      final token = response['jwt'];
      await SharedPrefs.saveToken(token);

      // Hiển thị toast trên cùng màn hình
      Fluttertoast.showToast(
        msg: "Đăng ký thành công!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Đăng ký thất bại! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP, // Hiển thị ở trên cùng màn hình
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 152, 221, 183),
                    Color.fromARGB(255, 238, 217, 189),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(top: 150),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Đăng ký',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Vui lòng nhập tên'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          bool isValidEmail = RegExp(
                                  r'^[a-zA-Z]+[\w-\.]*@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value.trim());
                          return isValidEmail
                              ? null
                              : 'Email không hợp lệ. \nPhần trước @ không được chỉ có số.';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _birthdayController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Ngày sinh',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Vui lòng chọn ngày sinh'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: _selectedCountryCode,
                            items: [
                              DropdownMenuItem(
                                value: '+84',
                                child: Text('+84'),
                                enabled:
                                    false, // Vô hiệu hóa, không thể chọn lại
                              )
                            ],
                            onChanged: null, // Không cho bấm
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Số điện thoại',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập SĐT'; // Không bắt buộc nhập
                                }

                                // Loại bỏ khoảng trắng và kiểm tra độ dài tối thiểu
                                String phone = value.trim();

                                // Nếu nhập số 0 đầu, giữ nguyên
                                if (phone.startsWith('0')) {
                                  phone =
                                      phone.substring(1); // Bỏ số 0 đầu tiên
                                }

                                // Regex kiểm tra đầu số hợp lệ của Việt Nam (bỏ số 0 đầu tiên)
                                bool isValidPhone = RegExp(
                                        r'^(32|33|34|35|36|37|38|39|81|82|83|84|85|70|76|77|78|79|56|58|59|87)\d{7}$')
                                    .hasMatch(phone);

                                return isValidPhone
                                    ? null
                                    : 'Số điện thoại không hợp lệ';
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          bool isValidPassword =
                              RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$')
                                  .hasMatch(value.trim());
                          return isValidPassword
                              ? null
                              : 'Mật khẩu phải thoả mãn các điều kiện: \n  Tối thiểu 8 ký tự, \n  Ít nhất 1 chữ hoa, chữ thường, ký tự đặc biệt';
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                          ),
                          onPressed: _register,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text('Đăng ký',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn đã có tài khoản?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Đăng nhập',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
