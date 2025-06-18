import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/constants/messages.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/presentation/screens/login/register_screen.dart';
import '../../controller/login/login_controller.dart';
import 'package:tms_app/core/utils/toast_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _controller = LoginController(loginUseCase: sl());

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Field error messages
  String? _emailError;
  String? _passwordError;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Tải thông tin đăng nhập đã lưu khi màn hình được khởi tạo
    _loadSavedLoginInfo();
  }

  // Phương thức tải thông tin đăng nhập đã lưu
  Future<void> _loadSavedLoginInfo() async {
    await _controller.loadSavedLoginInfo(
      _emailController,
      _passwordController,
      (value) {
        setState(() {
          _rememberMe = value;
        });
      },
    );
  }

  void _resetErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  // Xử lý đăng nhập
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _resetErrors();
      setState(() {
        _loading = true;
      });

      try {
        final response = await _controller.login(
          _emailController.text,
          _passwordController.text,
        );

        if (response['success']) {
          // Đăng nhập thành công
          ToastHelper.showSuccessToast(response['message']);

          // Lưu thông tin đăng nhập nếu "Nhớ mật khẩu" được chọn
          await _controller.saveLoginInfo(
            _emailController.text,
            _passwordController.text,
            _rememberMe,
          );

          // In JWT token ra console để test với Postman
          await _controller.printJwtToken();

          // Chuyển tới màn hình chính
          if (mounted) {
            _controller.navigateToHome(context);
          }
        } else {
          // Đăng nhập thất bại, hiển thị thông báo lỗi
          ToastHelper.showErrorToast(response['message']);

          // Hiển thị lỗi cho từng trường
          if (response.containsKey('errors') && response['errors'] != null) {
            final Map<String, dynamic> errors = response['errors'];
            setState(() {
              _emailError = errors['email'] as String?;
              _passwordError = errors['password'] as String?;
            });
          }
        }
      } catch (error) {
        ToastHelper.showErrorToast('Đăng nhập thất bại: $error');
      } finally {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  // Thêm phương thức để in JWT token từ màn hình đăng nhập (để test)
  void _printToken() async {
    try {
      await _controller.printJwtToken();
      ToastHelper.showSuccessToast("Token đã được in ra console");
    } catch (e) {
      ToastHelper.showErrorToast("Lỗi: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background with a more modern look
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.indigo.shade200,
                ],
                stops: const [0.3, 0.9],
              ),
            ),
          ),

          // Decorative circles at top
          Positioned(
            top: -50,
            left: -30,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withOpacity(0.2),
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: -50,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo or icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 50,
                            color: Colors.indigo.shade900,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TMS Learn Tech",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "Học tập - Phát triển - Thành công",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Login form card with glassmorphism effect
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: BackdropFilter(
                          filter: ColorFilter.mode(
                            Colors.black.withOpacity(0.05),
                            BlendMode.darken,
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "ĐĂNG NHẬP",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  "Đăng nhập để tiếp tục hành trình học tập",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.indigo.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 25),

                                // Email/Phone field
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      color: Colors.indigo.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Email hoặc số điện thoại',
                                    hintStyle: TextStyle(
                                        color: Colors.indigo.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.email,
                                        color: Colors.indigo.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.indigo.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.indigo.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    errorText: _emailError,
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppMessages.emptyEmailOrPhone;
                                    }

                                    final trimmed = value.trim();

                                    // Kiểm tra độ dài tối thiểu
                                    if (trimmed.length < 2) {
                                      return 'Email hoặc số điện thoại phải có ít nhất 2 ký tự';
                                    }

                                    // Kiểm tra nếu là email
                                    if (trimmed.contains('@')) {
                                      // Kiểm tra định dạng email
                                      if (!RegExp(
                                              r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
                                          .hasMatch(trimmed)) {
                                        return 'Định dạng email không hợp lệ';
                                      }

                                      // Kiểm tra email không bắt đầu bằng số
                                      if (RegExp(r'^[0-9]').hasMatch(trimmed)) {
                                        return 'Email không được bắt đầu bằng số';
                                      }

                                      // Kiểm tra phần tên miền
                                      final parts = trimmed.split('@');
                                      if (parts.length == 2) {
                                        if (parts[0].isEmpty) {
                                          return 'Tên người dùng trong email không được để trống';
                                        }
                                        if (parts[1].isEmpty ||
                                            !parts[1].contains('.')) {
                                          return 'Tên miền email không hợp lệ';
                                        }
                                      }
                                    }
                                    // Kiểm tra nếu là số điện thoại
                                    else {
                                      // Kiểm tra định dạng số điện thoại Việt Nam
                                      if (!RegExp(
                                              r'^(?:\+84|84|0)[3|5|7|8|9][0-9]{8}$')
                                          .hasMatch(trimmed)) {
                                        if (trimmed.length != 10 &&
                                            trimmed.length != 11) {
                                          return 'Số điện thoại phải có 10 hoặc 11 số';
                                        }
                                        if (!trimmed.startsWith('0') &&
                                            !trimmed.startsWith('+84') &&
                                            !trimmed.startsWith('84')) {
                                          return 'Số điện thoại phải bắt đầu bằng 0, +84 hoặc 84';
                                        }
                                        return 'Số điện thoại không hợp lệ';
                                      }
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                      color: Colors.indigo.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Mật khẩu',
                                    hintStyle: TextStyle(
                                        color: Colors.indigo.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Colors.indigo.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.indigo.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.indigo.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.indigo.shade400,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    errorText: _passwordError,
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() {
                                        _passwordError = null;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppMessages.emptyPassword;
                                    }

                                    final trimmed = value.trim();

                                    // Kiểm tra độ dài tối thiểu
                                    if (trimmed.length < 8) {
                                      return 'Mật khẩu phải có ít nhất 8 ký tự';
                                    }

                                    // Kiểm tra độ dài tối đa
                                    if (trimmed.length > 20) {
                                      return 'Mật khẩu không được quá 20 ký tự';
                                    }

                                    // Kiểm tra có ít nhất 1 chữ cái
                                    if (!RegExp(r'[a-zA-Z]')
                                        .hasMatch(trimmed)) {
                                      return 'Mật khẩu phải chứa ít nhất 1 chữ cái';
                                    }

                                    // Kiểm tra có ít nhất 1 số
                                    if (!RegExp(r'[0-9]').hasMatch(trimmed)) {
                                      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
                                    }

                                    // Kiểm tra khoảng trắng
                                    if (trimmed.contains(' ')) {
                                      return 'Mật khẩu không được chứa khoảng trắng';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                // Remember me and Forgot password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) => setState(
                                                () => _rememberMe = value!),
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return Colors.blueAccent;
                                                }
                                                return Colors.white
                                                    .withOpacity(0.5);
                                              },
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Nhớ mật khẩu',
                                          style: TextStyle(
                                            color: Colors.indigo.shade900,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => _controller
                                          .navigateToForgotPassword(context),
                                      child: Text(
                                        'Quên mật khẩu?',
                                        style: TextStyle(
                                          color: Colors.indigo.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                      shadowColor:
                                          Colors.black.withOpacity(0.2),
                                    ),
                                    onPressed: _loading ? null : _handleLogin,
                                    child: _loading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'ĐĂNG NHẬP',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Register link
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bạn chưa có tài khoản? ',
                              style: TextStyle(
                                color: Colors.indigo.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline,
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
          ),
        ],
      ),
    );
  }
}
