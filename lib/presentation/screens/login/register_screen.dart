import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import '../../controller/login/register_controller.dart';
import 'package:tms_app/core/constants/messages.dart'; // Import AppMessages

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _birthdayFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _loading = false;
  bool _obscurePassword = true;
  final RegisterController _controller = RegisterController(
    registerUseCase: sl(),
    accountRepository: sl(),
  );

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
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _birthdayFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _loading = true;
      });

      await _controller.register(
        _usernameController.text,
        _emailController.text,
        _birthdayController.text,
        _phoneController.text,
        _passwordController.text,
        context,
      );

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.green.shade800,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(
            DateTime(
                pickedDate.year, pickedDate.month, pickedDate.day, 0, 0, 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade200,
                  Colors.amber.shade200,
                ],
                stops: const [0.3, 0.9],
              ),
            ),
          ),

          // Decorative elements
          Positioned(
            top: -50,
            left: -30,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
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
                color: Colors.amber.withOpacity(0.15),
              ),
            ),
          ),

          // Main content with animation
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
                      // App logo and name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 50,
                            color: Colors.green.shade900,
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
                                  color: Colors.green.shade900,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "Tạo tài khoản của bạn",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Registration form card with glassmorphism
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
                                  "ĐĂNG KÝ",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
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
                                  "Điền thông tin để tạo tài khoản mới",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 25),

                                // Username field
                                TextFormField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocus,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Tên đăng nhập',
                                    hintText: 'Nhập tên đăng nhập',
                                    labelStyle:
                                        TextStyle(color: Colors.green.shade700),
                                    hintStyle:
                                        TextStyle(color: Colors.green.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.person,
                                        color: Colors.green.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? AppMessages.emptyUsername
                                      : null,
                                ),

                                const SizedBox(height: 16),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Nhập địa chỉ email',
                                    labelStyle:
                                        TextStyle(color: Colors.green.shade700),
                                    hintStyle:
                                        TextStyle(color: Colors.green.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.email,
                                        color: Colors.green.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppMessages.emptyEmail;
                                    }
                                    bool isValidEmail = RegExp(
                                      r'^[a-zA-Z]+[\w-\.]*@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value.trim());
                                    return isValidEmail
                                        ? null
                                        : AppMessages.invalidEmail;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Phone field
                                TextFormField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Số điện thoại',
                                    hintText: 'Nhập số điện thoại',
                                    labelStyle:
                                        TextStyle(color: Colors.green.shade700),
                                    hintStyle:
                                        TextStyle(color: Colors.green.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.phone,
                                        color: Colors.green.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppMessages.emptyPhone;
                                    }
                                    bool isValidPhone = RegExp(
                                      r'^(?:\+84|84|0)[3|5|7|8|9][0-9]{8}$',
                                    ).hasMatch(value.trim());
                                    return isValidPhone
                                        ? null
                                        : AppMessages.invalidPhone;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Birthday field
                                TextFormField(
                                  controller: _birthdayController,
                                  focusNode: _birthdayFocus,
                                  readOnly: true,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Ngày sinh',
                                    hintText: 'Chọn ngày sinh',
                                    labelStyle:
                                        TextStyle(color: Colors.green.shade700),
                                    hintStyle:
                                        TextStyle(color: Colors.green.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.cake,
                                        color: Colors.green.shade400),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_today,
                                          color: Colors.green.shade600),
                                      onPressed: () => _selectDate(context),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppMessages.emptyBirthday;
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectDate(context),
                                ),

                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    hintText: 'Nhập mật khẩu',
                                    labelStyle:
                                        TextStyle(color: Colors.green.shade700),
                                    hintStyle:
                                        TextStyle(color: Colors.green.shade400),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Colors.green.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.green.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.green.shade400,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppMessages.emptyPassword;
                                    }
                                    if (value.length < 6) {
                                      return AppMessages.passwordTooShort;
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 30),

                                // Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                      shadowColor:
                                          Colors.black.withOpacity(0.2),
                                    ),
                                    onPressed: _loading ? null : _register,
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
                                            'ĐĂNG KÝ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login link
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
                              'Bạn đã có tài khoản? ',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: Colors.amber.shade800,
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
