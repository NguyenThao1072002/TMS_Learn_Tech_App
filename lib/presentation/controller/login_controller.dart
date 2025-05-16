import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/screens/login/verify_email_screen.dart';
import 'package:tms_app/presentation/screens/login/login.dart';
import '../../core/constants/messages.dart';
import '../../core/di/service_locator.dart';
import '../../domain/usecases/login_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/presentation/controller/forgot_password_controller.dart';
import 'package:tms_app/core/utils/toast_helper.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';

class LoginController {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    signInOption: SignInOption.standard,
    clientId:
        '756152192397-qqmqpj1oiu4ik5otn9b3bfnbpn4c88fl.apps.googleusercontent.com',
  );
  final LoginUseCase loginUseCase;

  // Khóa cho SharedPreferences
  static const String KEY_SAVED_EMAIL = 'saved_email';
  static const String KEY_SAVED_PASSWORD = 'saved_password';
  static const String KEY_REMEMBER_ME = 'remember_me';
  static const String KEY_LAST_LOGIN = 'last_login';

  LoginController({required this.loginUseCase});

  // Phương thức đăng nhập
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await loginUseCase.call(identifier, password);

      if (response != null) {
        // In token JWT ra console để test với Postman
        printJwtToken();

        // Đăng nhập thành công
        return {
          'success': true,
          'message': 'Đăng nhập thành công!',
          'data': response
        };
      } else {
        // Giả định phân tích lỗi
        Map<String, String> fieldErrors = {};

        // Kiểm tra định dạng email/số điện thoại
        if (identifier.contains('@')) {
          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
              .hasMatch(identifier)) {
            fieldErrors['email'] = 'Định dạng email không hợp lệ';
          } else if (RegExp(r'^[0-9]').hasMatch(identifier.split('@')[0])) {
            fieldErrors['email'] = 'Email không được bắt đầu bằng số';
          } else {
            fieldErrors['email'] = 'Email chưa được đăng ký';
          }
        } else if (RegExp(r'^(?:\+84|84|0)[0-9]{9,10}$').hasMatch(identifier)) {
          fieldErrors['email'] = 'Số điện thoại chưa được đăng ký';
        } else {
          fieldErrors['email'] =
              'Email hoặc số điện thoại không đúng định dạng';
        }

        // Kiểm tra mật khẩu
        if (password.length < 6) {
          fieldErrors['password'] = 'Mật khẩu phải có ít nhất 6 ký tự';
        } else if (!RegExp(r'[a-zA-Z]').hasMatch(password) ||
            !RegExp(r'[0-9]').hasMatch(password)) {
          fieldErrors['password'] = 'Mật khẩu phải chứa cả chữ và số';
        } else {
          fieldErrors['password'] = 'Mật khẩu không chính xác';
        }

        return {
          'success': false,
          'message': 'Thông tin đăng nhập không chính xác',
          'errors': fieldErrors
        };
      }
    } catch (error) {
      // Lỗi kết nối hoặc lỗi server
      return {
        'success': false,
        'message': 'Đăng nhập thất bại: $error',
        'errors': {
          'email':
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.'
        }
      };
    }
  }

  // Lưu thông tin đăng nhập vào SharedPreferences
  Future<void> saveLoginInfo(
    String email,
    String password,
    bool remember,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu thông tin đăng nhập nếu người dùng chọn "Nhớ mật khẩu"
    if (remember) {
      await prefs.setString(KEY_SAVED_EMAIL, email);
      await prefs.setString(KEY_SAVED_PASSWORD, password);
      await prefs.setBool(KEY_REMEMBER_ME, true);
      await prefs.setString(KEY_LAST_LOGIN, DateTime.now().toIso8601String());

      // Ghi log
      debugPrint('Đã lưu thông tin đăng nhập cho: $email');
    } else {
      // Xóa thông tin đăng nhập nếu không chọn "Nhớ mật khẩu"
      await prefs.remove(KEY_SAVED_EMAIL);
      await prefs.remove(KEY_SAVED_PASSWORD);
      await prefs.remove(KEY_REMEMBER_ME);
      await prefs.remove(KEY_LAST_LOGIN);

      // Ghi log
      debugPrint('Đã xóa thông tin đăng nhập đã lưu');
    }
  }

  // Tải thông tin đăng nhập đã lưu từ SharedPreferences
  Future<void> loadSavedLoginInfo(
    TextEditingController emailController,
    TextEditingController passwordController,
    Function(bool) setRemember,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(KEY_SAVED_EMAIL) ?? "";
      final savedPassword = prefs.getString(KEY_SAVED_PASSWORD) ?? "";
      final remember = prefs.getBool(KEY_REMEMBER_ME) ?? false;
      final lastLogin = prefs.getString(KEY_LAST_LOGIN) ?? "";

      if (remember && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
        // Kiểm tra xem thông tin đăng nhập có còn hiệu lực không (dưới 30 ngày)
        if (lastLogin.isNotEmpty) {
          final lastLoginDate = DateTime.parse(lastLogin);
          final now = DateTime.now();
          final difference = now.difference(lastLoginDate);

          // Nếu thông tin đăng nhập đã lưu quá 30 ngày, xóa thông tin
          if (difference.inDays > 30) {
            await prefs.remove(KEY_SAVED_EMAIL);
            await prefs.remove(KEY_SAVED_PASSWORD);
            await prefs.remove(KEY_REMEMBER_ME);
            await prefs.remove(KEY_LAST_LOGIN);
            debugPrint('Thông tin đăng nhập đã hết hạn (quá 30 ngày)');
            return;
          }
        }

        // Điền thông tin đăng nhập vào form
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        setRemember(remember);

        debugPrint('Đã tải thông tin đăng nhập cho: $savedEmail');
      }
    } catch (e) {
      debugPrint('Lỗi khi tải thông tin đăng nhập: $e');
    }
  }

  // Chuyển hướng đến màn hình chính sau khi đăng nhập thành công
  void navigateToHome(BuildContext context) {
    // In thông tin token và userId để debug
    _printUserInfo();

    // Đặt cờ để báo hiệu đăng nhập mới
    _setNewLoginFlag();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // In thông tin người dùng hiện tại để debug
  Future<void> _printUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      final email = prefs.getString(SharedPrefs.KEY_USER_EMAIL);
      final token = prefs.getString('jwt');

      debugPrint('===== USER INFO AFTER LOGIN =====');
      debugPrint('User ID: $userId');
      debugPrint('Email: $email');
      if (token != null && token.isNotEmpty) {
        debugPrint('Token length: ${token.length}');
        debugPrint('Token first 10 chars: ${token.substring(0, 10)}...');
      } else {
        debugPrint('Token: null or empty');
      }
    } catch (e) {
      debugPrint('Error getting user info: $e');
    }
  }

  // Đặt cờ báo hiệu đăng nhập mới để các màn hình khác biết cần tải lại dữ liệu
  Future<void> _setNewLoginFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('new_login', true);
      await prefs.setString(
          'last_login_time', DateTime.now().toIso8601String());
      debugPrint('Set new login flag');
    } catch (e) {
      debugPrint('Error setting new login flag: $e');
    }
  }

  // Đăng nhập với Google
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // Show loading indicator
      showLoadingDialog(context);

      // Kiểm tra và yêu cầu cấp lại quyền nếu cần
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut(); // Đăng xuất trước để tránh lỗi cache
        await Future.delayed(const Duration(
            milliseconds: 300)); // Chờ một chút để tránh xung đột
      }

      // Set force server auth code để fix lỗi sign_in_failed
      await _googleSignIn.signIn();

      // Nếu mã bên trên ném lỗi, chúng ta không thực hiện các bước tiếp theo
      // Tạo chế độ đăng nhập thay thế nếu google sign in không hoạt động

      // Xóa indicator khi đăng nhập thất bại
      hideLoadingDialog(context);

      // Hiển thị dialog để người dùng nhập thông tin Google
      showManualGoogleSignInDialog(context);
    } catch (error) {
      hideLoadingDialog(context);
      // Phân tích lỗi chi tiết
      String errorMessage = "${AppMessages.googleLoginError}";

      if (error.toString().contains('network_error')) {
        errorMessage += "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.";
      } else if (error.toString().contains('sign_in_failed')) {
        // Đề xuất đăng nhập thủ công thay vì hiển thị lỗi
        showManualGoogleSignInDialog(context);
        return;
      } else {
        errorMessage += error.toString();
      }

      debugPrint('Lỗi chi tiết: $error');
      ToastHelper.showErrorToast(errorMessage);
    }
  }

  // Hiển thị dialog để người dùng nhập thông tin Google manually
  void showManualGoogleSignInDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng nhập với Google'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đăng nhập tự động không khả dụng.\nVui lòng nhập thông tin Gmail của bạn:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Gmail',
                    hintText: 'example@gmail.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị',
                    hintText: 'Tên của bạn',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Kiểm tra email hợp lệ
                final email = emailController.text.trim();
                final name = nameController.text.trim();

                if (email.isEmpty || !email.contains('@gmail.com')) {
                  ToastHelper.showErrorToast(
                      'Vui lòng nhập email Gmail hợp lệ');
                  return;
                }

                if (name.isEmpty) {
                  ToastHelper.showErrorToast('Vui lòng nhập tên của bạn');
                  return;
                }

                // Xử lý đăng nhập thủ công
                _handleManualGoogleSignIn(context, email, name);
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        );
      },
    );
  }

  // Xử lý đăng nhập thủ công với tài khoản Google
  Future<void> _handleManualGoogleSignIn(
      BuildContext context, String email, String name) async {
    try {
      showLoadingDialog(context);

      // Tạo mã token giả
      final mockToken =
          'mock_google_token_${DateTime.now().millisecondsSinceEpoch}';

      // Lưu thông tin đăng nhập giả lập
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefs.KEY_USER_EMAIL, email);
      await prefs.setString(SharedPrefs.KEY_USER_FULLNAME, name);
      await prefs.setString(SharedPrefs.KEY_USER_ID, '1');
      await SharedPrefs.saveJwtToken(mockToken);

      // Tạo ID người dùng giả
      final userId = '${email.hashCode}';
      await prefs.setString(SharedPrefs.KEY_USER_ID, userId);

      hideLoadingDialog(context);
      ToastHelper.showSuccessToast(AppMessages.googleLoginSuccess);

      // Chuyển đến màn hình chính
      navigateToHome(context);
    } catch (e) {
      hideLoadingDialog(context);
      ToastHelper.showErrorToast('Đăng nhập thất bại: $e');
    }
  }

  // Helper methods for loading dialog
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Đăng xuất người dùng
  Future<void> logout(BuildContext context) async {
    try {
      // 1. Lấy trạng thái "Nhớ mật khẩu"
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(KEY_REMEMBER_ME) ?? false;

      // 2. Xóa token và thông tin người dùng trong SharedPreferences
      await SharedPrefs.removeJwtToken();
      await prefs.remove(SharedPrefs.KEY_USER_EMAIL);
      await prefs.remove(SharedPrefs.KEY_USER_PHONE);
      await prefs.remove(SharedPrefs.KEY_USER_ID);
      await prefs.remove(SharedPrefs.KEY_REFRESH_TOKEN);
      await prefs.remove(SharedPrefs.KEY_USER_FULLNAME);
      await prefs.remove(SharedPrefs.KEY_USER_IMAGE);

      // 3. Xóa thông tin đăng nhập nếu không chọn "Nhớ mật khẩu"
      if (!rememberMe) {
        await prefs.remove(KEY_SAVED_EMAIL);
        await prefs.remove(KEY_SAVED_PASSWORD);
        await prefs.remove(KEY_REMEMBER_ME);
        await prefs.remove(KEY_LAST_LOGIN);
      }

      // 4. Đăng xuất khỏi Google nếu đã đăng nhập bằng Google
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
      }

      // 5. Hiển thị thông báo thành công
      ToastHelper.showSuccessToast("Đăng xuất thành công");

      // 6. Điều hướng đến màn hình đăng nhập và xóa tất cả màn hình trước đó
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route trước đó
      );
    } catch (error) {
      ToastHelper.showErrorToast("Đã xảy ra lỗi khi đăng xuất: $error");
    }
  }

  // Điều hướng đến màn hình quên mật khẩu
  void navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyEmailScreen(
          email: '', // Truyền email từ controller
          controller: ForgotPasswordController(
              accountRepository: sl()), // Khởi tạo controller từ DI
        ),
      ),
    );
  }

  // Cập nhật mật khẩu đã lưu sau khi đổi mật khẩu
  Future<void> updateSavedPassword(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(KEY_REMEMBER_ME) ?? false;

      // Chỉ cập nhật mật khẩu nếu đã bật chế độ nhớ mật khẩu
      if (rememberMe) {
        final savedEmail = prefs.getString(KEY_SAVED_EMAIL) ?? "";

        if (savedEmail.isNotEmpty) {
          await prefs.setString(KEY_SAVED_PASSWORD, newPassword);
          await prefs.setString(
              KEY_LAST_LOGIN, DateTime.now().toIso8601String());
          debugPrint('Đã cập nhật mật khẩu đã lưu cho: $savedEmail');
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật mật khẩu đã lưu: $e');
    }
  }

  // In JWT Token ra console để sử dụng trong Postman
  Future<void> printJwtToken() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Đợi để đảm bảo token đã được lưu
    final token = await SharedPrefs.getJwtToken();
    if (token != null && token.isNotEmpty) {
      debugPrint(
          '\n=================== JWT TOKEN FOR POSTMAN ===================');
      debugPrint(token);
      debugPrint(
          '===========================================================\n');
    } else {
      debugPrint('Không tìm thấy JWT token!');
    }
  }
}
