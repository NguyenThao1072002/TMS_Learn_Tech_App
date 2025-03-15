import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/screens/login/ForgotPassword/forgotPassword.dart';
import 'package:tms/screens/login/register.dart';
import '../../services/AccountServices.dart';
import '../../utils/shared_prefs.dart';
import '../homePage/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false; // Trạng thái "Nhớ mật khẩu"
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo(); // Tải thông tin đăng nhập nếu có
  }

  // Kiểm tra nếu đã lưu email/mật khẩu trước đó
  Future<void> _loadSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? "";
    final savedPassword = prefs.getString('saved_password') ?? "";
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      setState(() {
        _loginController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = remember;
      });
    }
  }

  // Hiển thị thông báo dạng Toast
  void showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP, // Hiển thị trên đầu màn hình
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Xử lý đăng nhập
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final response = await AccountServices.login(
      _loginController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (response != null) {
      final token = response['jwt'];
      await SharedPrefs.saveToken(token);

      // Nếu chọn "Nhớ mật khẩu", lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      if (_rememberMe) {
        prefs.setString('saved_email', _loginController.text.trim());
        prefs.setString('saved_password', _passwordController.text.trim());
        prefs.setBool('remember_me', true);
      } else {
        prefs.remove('saved_email');
        prefs.remove('saved_password');
        prefs.setBool('remember_me', false);
      }

      showToast('Đăng nhập thành công!', Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      showToast('Đăng nhập thất bại! Kiểm tra lại thông tin.', Colors.red);
    }
  }

// Xử lý đăng nhập bằng Google
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showToast('Đăng nhập Google bị hủy!', Colors.red);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
//chưa hàon thiện
      // Gửi token Google lên server (nếu cần)
      // final response =
      //     await AccountServices.loginWithGoogle(googleAuth.idToken!);

      // if (response != null) {
      //   final token = response['jwt'];
      //   await SharedPrefs.saveToken(token);

      //   showToast('Đăng nhập bằng Google thành công!', Colors.green);
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => HomeScreen()));
      // } else {
      //   showToast('Đăng nhập Google thất bại!', Colors.red);
      // }
    } catch (error) {
      showToast('Đăng nhập Google lỗi: $error', Colors.red);
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
                    Color.fromARGB(255, 199, 239, 245),
                    Color.fromARGB(255, 208, 197, 238),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 81, 212, 85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nhập email hoặc số điện thoại và mật khẩu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ô nhập Email/SĐT
                      TextFormField(
                        controller: _loginController,
                        keyboardType: TextInputType
                            .emailAddress, // Hỗ trợ nhập email/số điện thoại
                        decoration: InputDecoration(
                          hintText: 'Nhập email hoặc số điện thoại',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email hoặc số điện thoại';
                          }

                          String trimmedValue = value.trim();

                          // Kiểm tra email hợp lệ
                          bool isEmail =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(trimmedValue);

                          // Kiểm tra số điện thoại hợp lệ (10 hoặc 11 chữ số)
                          bool isPhone =
                              RegExp(r'^[0-9]{10}$').hasMatch(trimmedValue);

                          if (!isEmail && !isPhone) {
                            if (trimmedValue.contains('@')) {
                              return 'Email không hợp lệ';
                            } else {
                              return 'Số điện thoại không hợp lệ';
                            }
                          }

                          return null; // Không có lỗi
                        },
                      ),

                      const SizedBox(height: 12),

                      // Ô nhập Mật khẩu + Hiển thị mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mật khẩu không được để trống';
                          }

                          if (value.trim().length < 6) {
                            return 'Mật khẩu phải có ít nhất 8 ký tự';
                          }

                          return null; // Không có lỗi
                        },
                      ),

                      const SizedBox(height: 12),

                      // Nhớ mật khẩu + Quên mật khẩu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                },
                              ),
                              const Text('Nhớ mật khẩu'),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()));
                            },
                            child: const Text('Quên mật khẩu',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Nút Đăng nhập
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _login,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text('Đăng nhập',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hoặc đăng nhập với',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nút Đăng nhập bằng Google
                      SizedBox(
                        width: double.infinity, // Đặt chiều rộng tối đa
                        child: OutlinedButton.icon(
                          onPressed: _loginWithGoogle,
                          icon: FaIcon(FontAwesomeIcons.google,
                              color: Colors.red, size: 20),
                          label: Text(
                            "Đăng nhập bằng Google",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14), // Chiều cao nút
                            side: BorderSide(
                                color: Colors.grey.shade300), // Viền xám nhạt
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Bo góc nhẹ
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn chưa có tài khoản?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()));
                            },
                            child: const Text('Đăng ký',
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
