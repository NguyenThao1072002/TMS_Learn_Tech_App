import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/usecases/register_usecase.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class RegisterController {
  final RegisterUseCase registerUseCase;
  final AccountRepository accountRepository;

  RegisterController({
    required this.registerUseCase,
    required this.accountRepository,
  });

  Future<void> register(
    String name,
    String email,
    String birthday,
    String phone,
    String password,
    BuildContext context,
  ) async {
    try {
      // Gọi usecase để thực hiện đăng ký
      final response = await registerUseCase.call(
        name,
        email,
        birthday,
        phone,
        password,
      );

      if (response != null) {
        // Hiển thị thông báo toast thành công
        Fluttertoast.showToast(
          msg: "Đăng ký thành công!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppStyles.successToastBackgroundColor,
          textColor: AppStyles.toastTextColor,
          fontSize: AppStyles.toastFontSize,
        );

        // Chuyển hướng tới màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Hiển thị thông báo toast thất bại
        Fluttertoast.showToast(
          msg: "Đăng ký thất bại! Vui lòng thử lại.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppStyles.errorToastBackgroundColor,
          textColor: AppStyles.toastTextColor,
          fontSize: AppStyles.toastFontSize,
        );
      }
    } catch (error) {
      // Hiển thị thông báo lỗi nếu có exception xảy ra
      Fluttertoast.showToast(
        msg: "Đăng ký thất bại! $error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: AppStyles.errorToastBackgroundColor,
        textColor: AppStyles.toastTextColor,
        fontSize: AppStyles.toastFontSize,
      );
    }
  }
}
