import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class AppThemes {
  // Light theme - Giao diện mặc định
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    primaryColor: AppStyles.lightPrimaryColor,
    hintColor: Colors.orange.shade200,
    scaffoldBackgroundColor: AppStyles.lightBackgroundColor,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppStyles.lightTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppStyles.lightTextSecondaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppStyles.lightTextSecondaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppStyles.lightTextSecondaryColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppStyles.lightBackgroundColor,
      foregroundColor: AppStyles.lightTextColor,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppStyles.lightTextColor),
    ),
    cardTheme: CardTheme(
      color: AppStyles.lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerColor: AppStyles.lightDividerColor,
    iconTheme: const IconThemeData(
      color: AppStyles.lightIconColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppStyles.lightPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyles.lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.orange,
      accentColor: Colors.orangeAccent,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    primaryColor: AppStyles.darkPrimaryColor,
    hintColor: Colors.orange.shade200,
    scaffoldBackgroundColor: AppStyles.darkBackgroundColor,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppStyles.darkTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppStyles.darkTextSecondaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppStyles.darkTextSecondaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppStyles.darkTextSecondaryColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppStyles.darkCardColor,
      foregroundColor: AppStyles.darkTextColor,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppStyles.darkTextColor),
    ),
    cardTheme: CardTheme(
      color: AppStyles.darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerColor: AppStyles.darkDividerColor,
    iconTheme: const IconThemeData(
      color: AppStyles.darkIconColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppStyles.darkPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyles.darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.orange,
      accentColor: Colors.orangeAccent,
      brightness: Brightness.dark,
    ),
  );
}
