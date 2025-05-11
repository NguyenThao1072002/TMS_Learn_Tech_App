import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class ForgotPasswordController {
  final AccountRepository accountRepository;
  final RxString errorMessage = ''.obs;

  ForgotPasswordController({
    required this.accountRepository,
  });

  Future<Map<String, String?>> getUserData() async {
    try {
      return await accountRepository.getUserData();
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: ${e.toString()}');
    }
  }

  Future<bool> sendOtpToEmail(String email) async {
    try {
      return await accountRepository.sendOtpToEmail({'email': email});
    } catch (e) {
      throw Exception('Không thể gửi mã OTP: ${e.toString()}');
    }
  }

  // Future<bool> sendOtpToPhone(String phone) async {
  //   try {
  //     final result = await accountRepository.sendOtpToPhone({'phone': phone});
  //     return result;
  //   } catch (e) {
  //     errorMessage.value =
  //         'Không thể gửi mã OTP qua số điện thoại: ${e.toString()}'; // Gán thông báo lỗi
  //     return false;
  //   }
  // }

  Future<bool> verifyOtp(String otp, String email) async {
    try {
      return await accountRepository.verifyOtp({
        'otp': otp,
        'email': email,
      });
    } catch (e) {
      throw Exception('Không thể xác thực mã OTP: ${e.toString()}');
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      return await accountRepository.updatePassword({
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật mật khẩu: ${e.toString()}');
    }
  }

  void showToast(String message, bool isError) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: isError
          ? AppStyles.errorToastBackgroundColor
          : AppStyles.successToastBackgroundColor,
      textColor: AppStyles.toastTextColor,
      fontSize: AppStyles.toastFontSize,
    );
  }
}
