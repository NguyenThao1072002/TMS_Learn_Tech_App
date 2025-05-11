import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import '../../controller/register_controller.dart';
import 'package:tms_app/core/constants/messages.dart'; // Import AppMessages

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  @override
  void dispose() {
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _birthdayFocus.dispose();
    _passwordFocus.dispose();
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
                    Color.fromARGB(255, 102, 204, 255),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.1,
                  horizontal: AppDimensions.screenPadding,
                ),
                child: Container(
                  width: 370,
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.formSpacing),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Tên đăng nhập',
                            filled: true,
                            fillColor: Colors.white,
                            border: AppStyles.inputBorder,
                            errorStyle: const TextStyle(height: 0.8),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? AppMessages.emptyUsername
                              : null,
                        ),
                        const SizedBox(height: AppDimensions.formSpacing),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Nhập email',
                            filled: true,
                            fillColor: Colors.white,
                            border: AppStyles.inputBorder,
                            errorStyle: const TextStyle(height: 0.8),
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
                        const SizedBox(height: AppDimensions.formSpacing),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Số điện thoại',
                            filled: true,
                            fillColor: Colors.white,
                            border: AppStyles.inputBorder,
                            errorStyle: const TextStyle(height: 0.8),
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
                        const SizedBox(height: AppDimensions.formSpacing),
                        TextFormField(
                          controller: _birthdayController,
                          decoration: InputDecoration(
                            hintText: 'Ngày sinh',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: AppStyles.inputBorder,
                            errorStyle: const TextStyle(height: 0.8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppMessages.emptyBirthday;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.formSpacing),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu',
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
                            if (value == null || value.isEmpty) {
                              return AppMessages.emptyPassword;
                            }
                            if (value.length < 6) {
                              return AppMessages.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: AppStyles.elevatedButtonStyle,
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Đăng ký',
                                    style: AppStyles.whiteButtonText,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Bạn đã có tài khoản? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Đăng nhập',
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
          ],
        ),
      ),
    );
  }
}
