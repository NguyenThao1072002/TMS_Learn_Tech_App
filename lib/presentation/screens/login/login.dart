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
    final loginUseCase = GetIt.instance<LoginUseCase>();
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
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Nhập email hoặc số điện thoại',
                                filled: true,
                                fillColor: Colors.white,
                                border: AppStyles.inputBorder,
                                errorStyle: const TextStyle(height: 0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppMessages.emptyEmailOrPhone;
                                }
                                final trimmed = value.trim();
                                final isEmail = RegExp(
                                  r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                                ).hasMatch(trimmed);
                                final isPhone = RegExp(
                                  r'^(?:\+84|84|0)[3|5|7|8|9][0-9]{8}$',
                                ).hasMatch(trimmed);
                                if (!isEmail && !isPhone) {
                                  return trimmed.contains('@')
                                      ? AppMessages.invalidEmail
                                      : AppMessages.invalidPhone;
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
                                errorStyle: const TextStyle(height: 0.8),
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
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppMessages.emptyPassword;
                                }
                                if (value.trim().length < 6) {
                                  return AppMessages.passwordTooShort;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {});
                                }
                              },
                              onEditingComplete: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {});
                                }
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
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    setState(() {
                                      _loading = true;
                                    });

                                    final response = await loginUseCase.call(
                                      _emailController.text,
                                      _passwordController.text,
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      _loading = false;
                                    });

                                    if (response != null) {
                                      await _controller.saveLoginInfo(
                                        _emailController.text,
                                        _passwordController.text,
                                        _rememberMe,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
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
