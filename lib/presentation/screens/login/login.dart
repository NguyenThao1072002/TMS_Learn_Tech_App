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
import '../../controller/login_controller.dart';
import 'package:tms_app/core/utils/toast_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  void initState() {
    super.initState();

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
    super.dispose();
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
                    AppStyles.backgroundGradientStart,
                    AppStyles.backgroundGradientEnd,
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.13,
                  ),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Đăng nhập', style: AppStyles.heading),
                            const SizedBox(height: AppDimensions.formSpacing),
                            const Text(
                              'Nhập email hoặc số điện thoại và mật khẩu',
                              style: AppStyles.subText,
                            ),
                            const SizedBox(
                                height: AppDimensions.headingSpacing),
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Nhập email hoặc số điện thoại',
                                filled: true,
                                fillColor: Colors.white,
                                border: AppStyles.inputBorder,
                                errorText: _emailError,
                                errorStyle: const TextStyle(
                                    height: 0.8, color: Colors.red),
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
                            const SizedBox(height: AppDimensions.formSpacing),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Nhập mật khẩu',
                                filled: true,
                                fillColor: Colors.white,
                                border: AppStyles.inputBorder,
                                errorText: _passwordError,
                                errorStyle: const TextStyle(
                                    height: 0.8, color: Colors.red),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
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
                                if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
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
                            const SizedBox(height: AppDimensions.formSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) =>
                                          setState(() => _rememberMe = value!),
                                    ),
                                    const Text('Nhớ mật khẩu',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => _controller
                                      .navigateToForgotPassword(context),
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.blockSpacing),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: AppStyles.elevatedButtonStyle,
                                onPressed: _loading ? null : _handleLogin,
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: AppStyles.whiteButtonText,
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.formSpacing),
                            const Text(
                              'Hoặc đăng nhập với',
                              style: AppStyles.subText,
                            ),
                            const SizedBox(height: AppDimensions.formSpacing),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _controller.loginWithGoogle(context),
                                icon: const FaIcon(
                                  FontAwesomeIcons.google,
                                  color: AppStyles.googleColor,
                                  size: 20,
                                ),
                                label: const Text(
                                  "Đăng nhập bằng Google",
                                  style: AppStyles.blackButtonText,
                                ),
                                style: AppStyles.outlinedButtonStyle,
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.headingSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Bạn chưa có tài khoản? '),
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
                                  child: const Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
