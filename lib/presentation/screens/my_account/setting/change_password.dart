import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/account/change_password.dart';
import 'package:tms_app/domain/usecases/change_password_usecase.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/controller/login_controller.dart';
import 'package:tms_app/presentation/screens/login/login.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controllers cho các ô input
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Trạng thái hiển thị/ẩn mật khẩu
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  // Trạng thái hợp lệ của mật khẩu
  bool _isCurrentPasswordValid = true;
  bool _isNewPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isLoading = false;

  // Thông báo lỗi
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  // GlobalKey cho form
  final _formKey = GlobalKey<FormState>();

  // Kiểm tra độ mạnh của mật khẩu
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  // Lấy instance của ChangePasswordUseCase
  late final ChangePasswordUseCase _changePasswordUseCase;

  // Lấy instance của LoginController để cập nhật mật khẩu đã lưu
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo use case từ service locator
    _changePasswordUseCase = sl<ChangePasswordUseCase>();

    // Khởi tạo login controller
    _loginController = LoginController(loginUseCase: sl());
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Kiểm tra độ mạnh của mật khẩu
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = PasswordStrength.weak;
      });
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (password.length >= 8) strength++;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = PasswordStrength.weak;
      } else if (strength <= 4) {
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.strong;
      }
    });
  }

  // Xử lý khi thay đổi mật khẩu
  Future<void> _changePassword() async {
    // Kiểm tra form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra mật khẩu mới và xác nhận có trùng khớp không
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _isConfirmPasswordValid = false;
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
      });
      return;
    }

    // Đặt trạng thái loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo model đổi mật khẩu
      final changePasswordModel = ChangePasswordModel(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      // Gọi API đổi mật khẩu
      final result = await _changePasswordUseCase.execute(changePasswordModel);

      // Dừng loading
      setState(() {
        _isLoading = false;
      });

      if (result) {
        // Cập nhật mật khẩu mới vào SharedPreferences nếu đổi thành công
        await _updateStoredPassword(_newPasswordController.text);
        // Thành công
        _showChangePasswordSuccessDialog();
      } else {
        // Thất bại - hiển thị lỗi cụ thể về mật khẩu hiện tại
        _showChangePasswordFailedDialog(
            errorMessage:
                'Mật khẩu hiện tại không đúng. Vui lòng kiểm tra lại.');

        // Đánh dấu ô mật khẩu hiện tại là không hợp lệ và focus vào nó
        setState(() {
          _isCurrentPasswordValid = false;
          _currentPasswordError = 'Mật khẩu hiện tại không đúng';
        });

        // Focus trở lại vào ô mật khẩu hiện tại
        FocusScope.of(context).requestFocus(FocusNode());
        _currentPasswordController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _currentPasswordController.text.length,
        );
      }
    } catch (e) {
      // Xử lý lỗi
      setState(() {
        _isLoading = false;
      });
      _showChangePasswordFailedDialog(errorMessage: e.toString());
    }
  }

  // Cập nhật mật khẩu đã lưu trong SharedPreferences
  Future<void> _updateStoredPassword(String newPassword) async {
    try {
      // Cập nhật mật khẩu mới trong LoginController
      await _loginController.updateSavedPassword(newPassword);

      // Cập nhật các thông tin bổ sung
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'password_change_time', DateTime.now().toIso8601String());
    } catch (e) {
      // Ghi log lỗi nếu cần
      print('Không thể cập nhật mật khẩu đã lưu: $e');
    }
  }

  // Hiển thị dialog thông báo đổi mật khẩu thành công
  void _showChangePasswordSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon thành công
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Đổi mật khẩu thành công! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Nội dung
                const Text(
                  'Mật khẩu mới của bạn đã được cập nhật.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Thông báo đăng nhập lại
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Bạn sẽ được đưa về màn hình đăng nhập',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Vui lòng đăng nhập lại bằng mật khẩu mới.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nút trở về màn hình đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Đăng xuất và đưa về màn hình đăng nhập
                      _navigateToLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập lại',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Phương thức đưa người dùng về màn hình đăng nhập
  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Xóa tất cả các route trước đó
    );
  }

  // Đăng xuất khỏi tất cả thiết bị khác
  Future<void> _logoutFromOtherDevices() async {
    try {
      // TODO: Gọi API đăng xuất khỏi thiết bị khác (cần thực hiện sau)
      // API có thể sẽ cần thêm ở phía backend
      // Có thể thực hiện bằng cách vô hiệu hóa tất cả refresh token cũ
      // và chỉ giữ lại token hiện tại

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất khỏi tất cả thiết bị khác'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đăng xuất khỏi thiết bị khác'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hiển thị dialog thông báo đổi mật khẩu thất bại
  void _showChangePasswordFailedDialog({String? errorMessage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon thất bại
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.red,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Oops! Có gì đó không ổn 😕',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Nội dung
                Text(
                  errorMessage ??
                      'Đổi mật khẩu không thành công. Vui lòng thử lại sau nhé!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Nút đóng
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin mật khẩu hiện tại
                  _buildInfoSection(
                    title: 'Đổi mật khẩu tài khoản',
                    description:
                        'Nhập mật khẩu hiện tại và mật khẩu mới để thay đổi mật khẩu đăng nhập của bạn.',
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),

                  // Mật khẩu hiện tại
                  _buildPasswordField(
                    label: 'Mật khẩu hiện tại',
                    controller: _currentPasswordController,
                    isVisible: _currentPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _currentPasswordVisible = !_currentPasswordVisible;
                      });
                    },
                    isValid: _isCurrentPasswordValid,
                    errorText: _currentPasswordError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Mật khẩu mới
                  _buildPasswordField(
                    label: 'Mật khẩu mới',
                    controller: _newPasswordController,
                    isVisible: _newPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                    isValid: _isNewPasswordValid,
                    errorText: _newPasswordError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'Mật khẩu mới không được trùng với mật khẩu hiện tại';
                      }
                      if (value.length < 8) {
                        return 'Mật khẩu phải có ít nhất 8 ký tự';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _checkPasswordStrength(value);
                    },
                  ),

                  // Thanh đánh giá độ mạnh mật khẩu
                  if (_newPasswordController.text.isNotEmpty)
                    _buildPasswordStrengthIndicator(),

                  const SizedBox(height: 20),

                  // Xác nhận mật khẩu mới
                  _buildPasswordField(
                    label: 'Xác nhận mật khẩu mới',
                    controller: _confirmPasswordController,
                    isVisible: _confirmPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                    isValid: _isConfirmPasswordValid,
                    errorText: _confirmPasswordError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu mới';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Nút Đổi mật khẩu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Hướng dẫn mật khẩu mạnh
                  _buildPasswordTips(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thông tin phần
  Widget _buildInfoSection({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị ô nhập mật khẩu
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    required bool isValid,
    String? errorText,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
            hintText: 'Nhập ${label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            errorText: isValid ? null : errorText,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị thanh độ mạnh mật khẩu
  Widget _buildPasswordStrengthIndicator() {
    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (_passwordStrength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthText = 'Yếu';
        strengthValue = 0.3;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthText = 'Trung bình';
        strengthValue = 0.6;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthText = 'Mạnh';
        strengthValue = 1.0;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Độ mạnh mật khẩu: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strengthValue,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tips mật khẩu mạnh
  Widget _buildPasswordTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Mẹo tạo mật khẩu mạnh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Sử dụng ít nhất 8 ký tự'),
          _buildTipItem('Kết hợp chữ hoa và chữ thường'),
          _buildTipItem('Bao gồm ít nhất một số'),
          _buildTipItem('Thêm ký tự đặc biệt (!, @, #, \$, %, ^, &, *)'),
          _buildTipItem('Không sử dụng thông tin cá nhân dễ đoán'),
        ],
      ),
    );
  }

  // Widget hiển thị mỗi mẹo
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum đánh giá độ mạnh mật khẩu
enum PasswordStrength {
  weak,
  medium,
  strong,
}
