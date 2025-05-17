import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordController extends GetxController {
  final AccountRepository accountRepository;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final RxString errorMessage = ''.obs;

  // Variables for email and loading state
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;

  ForgotPasswordController({
    required this.accountRepository,
  }) : _forgotPasswordUseCase = ForgotPasswordUseCase(accountRepository);

  // Lấy thông tin người dùng
  Future<Map<String, String?>> getUserData() async {
    try {
      isLoading.value = true;
      final userData = await _forgotPasswordUseCase.getUserData();
      isLoading.value = false;
      return userData;
    } catch (e) {
      isLoading.value = false;
      throw Exception('Lỗi: $e');
    }
  }

  // Gửi OTP qua email
  Future<bool> sendOtpToEmail(String email) async {
    try {
      isLoading.value = true;
      final result = await _forgotPasswordUseCase.sendOtpToEmail(email);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      throw Exception('Không thể gửi mã OTP: ${e.toString()}');
    }
  }

  // Xác thực OTP
  Future<bool> verifyOtp(String otp, String email) async {
    try {
      isLoading.value = true;
      final result = await _forgotPasswordUseCase.verifyOtp(otp, email);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      throw Exception('Không thể xác thực mã OTP: ${e.toString()}');
    }
  }

  // Cập nhật mật khẩu
  Future<bool> updatePassword(String newPassword,
      {required String email, required String otp}) async {
    try {
      isLoading.value = true;
      final result = await _forgotPasswordUseCase.updatePassword(newPassword,
          email: email, otp: otp);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      throw Exception('Không thể cập nhật mật khẩu: ${e.toString()}');
    }
  }

  // Gửi yêu cầu quên mật khẩu
  Future<bool> requestForgotPasswordOtp(String userEmail) async {
    try {
      isLoading.value = true;
      email.value = userEmail;

      final result =
          await _forgotPasswordUseCase.requestForgotPasswordOtp(userEmail);

      isLoading.value = false;
      isOtpSent.value = result;

      return result;
    } catch (e) {
      isLoading.value = false;
      throw Exception('Lỗi khi yêu cầu mã OTP: $e');
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
