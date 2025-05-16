import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/account/change_password.dart';
import 'package:tms_app/domain/usecases/change_password_usecase.dart';
import 'package:tms_app/core/DI/service_locator.dart';

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

  @override
  void initState() {
    super.initState();
    // Khởi tạo use case từ service locator
    _changePasswordUseCase = sl<ChangePasswordUseCase>();
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
        // Thành công
        _showChangePasswordSuccessDialog();
      } else {
        // Thất bại
        _showChangePasswordFailedDialog();
      }
    } catch (e) {
      // Xử lý lỗi
      setState(() {
        _isLoading = false;
      });
      _showChangePasswordFailedDialog(errorMessage: e.toString());
    }
  }

  // Hiển thị dialog thông báo đổi mật khẩu thành công
  void _showChangePasswordSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Thành công'),
            ],
          ),
          content: const Text('Mật khẩu của bạn đã được thay đổi thành công.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Đóng',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị dialog thông báo đổi mật khẩu thất bại
  void _showChangePasswordFailedDialog({String? errorMessage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Thất bại'),
            ],
          ),
          content: Text(errorMessage ??
              'Đổi mật khẩu không thành công. Vui lòng thử lại sau.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Đóng',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
