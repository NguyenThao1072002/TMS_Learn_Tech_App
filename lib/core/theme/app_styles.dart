import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

// Các TextStyles
class AppStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 81, 212, 85),
  );

  static const TextStyle subText = TextStyle(fontSize: 14, color: Colors.grey);

  static const TextStyle whiteButtonText = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle blackButtonText = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  // Button styles
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppStyles.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: AppDimensions.buttonHeight),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: AppDimensions.buttonHeight),
    side: BorderSide(color: AppStyles.borderColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusRounded),
    ),
  );

  // Border styles
  static final OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static final OutlineInputBorder roundedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
  );

  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color googleColor = Colors.red;
  static const Color borderColor = Color.fromARGB(255, 235, 235, 235);
  static const Color backgroundGradientStart =
      Color.fromARGB(255, 199, 239, 245);
  static const Color backgroundGradientEnd = Color.fromARGB(255, 208, 197, 238);

  // Toast Styles
  static const Color successToastBackgroundColor = Colors.green;
  static const Color errorToastBackgroundColor = Colors.red;
  static const Color infoToastBackgroundColor = Colors.blue;
  static const Color toastTextColor = Colors.white;
  static const double toastFontSize = 16.0;

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: Colors.black,
  );

  static const TextStyle discoverSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle discoverTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

// static const TextStyle sectionTitle = TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.bold,
//     color: Colors.black,
//   );

  static const TextStyle whiteTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle italicWhite = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: Colors.red,
    fontWeight: FontWeight.w500,
  );
}
