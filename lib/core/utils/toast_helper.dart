import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart'; // Import AppStyles

class ToastHelper {
  // Hàm để hiển thị Toast với thông báo và màu sắc tùy chỉnh
  static void showToast({
    required String msg,
    required Color backgroundColor,
    Color textColor = AppStyles.toastTextColor,
    Toast toastLength = Toast.LENGTH_SHORT,
    double fontSize = AppStyles.toastFontSize,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: ToastGravity.TOP,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  // Các hàm tiện ích cho các loại thông báo cụ thể
  static void showSuccessToast(String msg) {
    showToast(
      msg: msg,
      backgroundColor: AppStyles.successToastBackgroundColor,
    );
  }

  static void showErrorToast(String msg) {
    showToast(
      msg: msg,
      backgroundColor: AppStyles.errorToastBackgroundColor,
    );
  }

  static void showInfoToast(String msg) {
    showToast(
      msg: msg,
      backgroundColor: AppStyles.infoToastBackgroundColor,
    );
  }
}
