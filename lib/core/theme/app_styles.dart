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

  // Course detail styles
  static const Color backgroundColor = Colors.white;
  static const Color borderColorLight = Color(0xFFDDDDDD);
  static const Color tabActiveColor = Colors.blue;
  static const Color tabInactiveColor = Colors.grey;

  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: AppDimensions.appBarTitleSize,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle snackBarTextStyle = TextStyle(
    fontSize: 16,
  );

  static BoxDecoration tabBarDecoration = BoxDecoration(
    color: backgroundColor,
    border: Border(
      bottom: BorderSide(
        color: Colors.grey.shade300,
        width: AppDimensions.borderWidth,
      ),
    ),
  );

  // Review styles
  static const Color amberColor = Colors.amber;
  static const Color ratingCircleColor =
      Color(0xFFFFECB3); // Colors.amber.shade100
  static const Color ratingTextColor =
      Color(0xFFFF8F00); // Colors.amber.shade800
  static const Color reviewCardShadowColor =
      Color(0x0D000000); // Colors.black.withOpacity(0.05)
  static const Color reviewFilterBgColor =
      Color(0xFFE3F2FD); // Colors.blue.shade50
  static const Color reviewFilterTextColor =
      Color(0xFF1976D2); // Colors.blue.shade700
  static const Color emptyReviewBgColor =
      Color(0xFFFAFAFA); // Colors.grey.shade50
  static const Color emptyReviewBorderColor =
      Color(0xFFEEEEEE); // Colors.grey.shade200
  static const Color emptyReviewIconColor =
      Color(0xFFBDBDBD); // Colors.grey.shade400
  static const Color emptyReviewTextColor =
      Color(0xFF757575); // Colors.grey.shade600

  static const TextStyle ratingValueStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ratingTextColor,
  );

  static const TextStyle ratingCountStyle = TextStyle(
    color: Color(0xFF757575), // Colors.grey.shade600
    fontSize: 12,
  );

  static const TextStyle reviewTitleStyle = TextStyle(
    fontSize: AppDimensions.ratingTitleSize,
    fontWeight: FontWeight.bold,
    color: Color(0xFF424242), // Colors.grey.shade800
  );

  static const TextStyle filterChipStyle = TextStyle(
    color: reviewFilterTextColor,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static const TextStyle emptyReviewStyle = TextStyle(
    fontStyle: FontStyle.italic,
    color: emptyReviewTextColor,
  );

  static const TextStyle reviewButtonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1565C0), // Colors.blue.shade800
  );

  static const TextStyle writeReviewTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1565C0), // Colors.blue.shade800
  );

  static const TextStyle writeReviewDescriptionStyle = TextStyle(
    color: Color(0xFF1976D2), // Colors.blue.shade700
  );

  static BoxDecoration reviewCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: reviewCardShadowColor,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration filterChipDecoration = BoxDecoration(
    color: reviewFilterBgColor,
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration emptyReviewDecoration = BoxDecoration(
    color: emptyReviewBgColor,
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    border: Border.all(
      color: emptyReviewBorderColor,
      width: AppDimensions.borderWidth,
    ),
  );

  static BoxDecoration viewMoreButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFFFCA28), // Colors.amber.shade400
        Color(0xFFFFB300), // Colors.amber.shade600
      ],
    ),
    borderRadius: BorderRadius.circular(AppDimensions.reviewButtonBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Color(0x4DFFCA28), // Colors.amber.withOpacity(0.3)
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  );

  static ButtonStyle viewMoreButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: EdgeInsets.symmetric(horizontal: AppDimensions.standardPadding),
  );

  static BoxDecoration writeReviewContainerDecoration = BoxDecoration(
    color: Color(0xFFE3F2FD), // Colors.blue.shade50
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
  );

  static BoxDecoration writeReviewButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF42A5F5), // Colors.blue.shade400
        Color(0xFF1976D2), // Colors.blue.shade700
      ],
    ),
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Color(0x4D42A5F5), // Colors.blue.withOpacity(0.3)
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration writeReviewButtonDisabledDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFBDBDBD), // Colors.grey.shade400
        Color(0xFF757575), // Colors.grey.shade600
      ],
    ),
    borderRadius: BorderRadius.circular(22),
  );

  // Info general course styles
  static const Color categoryChipColor =
      Color(0xFF1976D2); // Colors.blue.shade600
  static const Color levelChipBgColor =
      Color(0xFFFFECB3); // Colors.amber.shade100
  static const Color levelChipTextColor =
      Color(0xFFFF8F00); // Colors.amber.shade800
  static const Color teacherChipBgColor = Colors.white;
  static const Color teacherChipTextColor =
      Color(0xFF1565C0); // Colors.blue.shade800
  static const Color gradientOverlayStartColor =
      Color(0x80000000); // Colors.black.withOpacity(0.5)
  static const Color gradientOverlayEndColor =
      Color(0xD9000000); // Colors.black.withOpacity(0.85)
  static const Color ratingChipBgColor = Colors.amber;
  static const Color ratingChipTextColor = Colors.white;

  static const TextStyle categoryChipStyle = TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.chipFontSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelChipStyle = TextStyle(
    color: levelChipTextColor,
    fontSize: AppDimensions.chipFontSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle teacherChipStyle = TextStyle(
    color: teacherChipTextColor,
    fontSize: AppDimensions.chipFontSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle courseTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.courseTitleSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statsTextStyle = TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.statsTextSize,
  );

  static const TextStyle statsRatingStyle = TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.statsTextSize,
    fontWeight: FontWeight.bold,
  );

  static BoxDecoration categoryChipDecoration = BoxDecoration(
    color: categoryChipColor,
    borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
  );

  static BoxDecoration levelChipDecoration = BoxDecoration(
    color: levelChipBgColor,
    borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
  );

  static BoxDecoration teacherChipDecoration = BoxDecoration(
    color: teacherChipBgColor,
    borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
  );

  static BoxDecoration ratingChipDecoration = BoxDecoration(
    color: ratingChipBgColor,
    borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
  );

  static Gradient headerGradientOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      gradientOverlayStartColor,
      gradientOverlayEndColor,
    ],
  );

  static Gradient defaultHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1565C0), // Colors.blue.shade800
      Color(0xFF1976D2), // Colors.blue.shade600
    ],
  );

  // Structured course styles
  static const Color chapterCompletedColor = Colors.green;
  static const Color chapterInProgressColor = Colors.amber;
  static const Color chapterNotStartedColor = Colors.grey;
  static const Color lessonCompletedColor = Colors.green;
  static const Color lessonInProgressColor = Colors.amber;
  static const Color lessonNotStartedColor = Colors.grey;
  static const Color lessonLockedColor = Colors.grey;

  static const TextStyle chapterTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle chapterDetailStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle lessonTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle lessonDurationStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static BoxDecoration chapterItemDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Navbar Add to Card styles
  static const Color navbarBgColor = Colors.white;
  static const Color navbarShadowColor =
      Color(0x0D000000); // Colors.black.withOpacity(0.05)
  static const Color priceColor = Colors.blue;
  static const Color oldPriceColor = Colors.grey;
  static const Color addToCartBgColor =
      Color(0xFFE3F2FD); // Colors.blue.shade50
  static const Color addToCartBorderColor =
      Color(0xFF90CAF9); // Colors.blue.shade300
  static const Color addToCartIconColor = Colors.blue;
  static const Color registerButtonBgColor = Colors.blue;
  static const Color registerButtonTextColor = Colors.white;

  static const TextStyle priceTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: priceColor,
  );

  static const TextStyle oldPriceTextStyle = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    color: oldPriceColor,
  );

  static const TextStyle registerButtonTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static BoxDecoration navbarBoxDecoration = BoxDecoration(
    color: navbarBgColor,
    boxShadow: [
      BoxShadow(
        color: navbarShadowColor,
        blurRadius: 10,
        offset: Offset(0, -5),
      ),
    ],
  );

  static BoxDecoration continueStudyButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF66BB6A),
        Color(0xFF388E3C)
      ], // Colors.green.shade400, Colors.green.shade700
    ),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Color(0x4D4CAF50), // Colors.green.withOpacity(0.3)
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration addToCartButtonDecoration = BoxDecoration(
    color: addToCartBgColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: addToCartBorderColor),
  );

  static ButtonStyle continueStudyButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );

  static ButtonStyle registerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: registerButtonBgColor,
    foregroundColor: registerButtonTextColor,
    padding: EdgeInsets.symmetric(horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Course screen styles
  static const Color courseScreenBgColor = Colors.white;
  static const Color appBarColor = Colors.blue;
  static const Color filterButtonBgColor = Colors.blue;
  static const Color filterButtonSelectedColor =
      Color(0xFF0D47A1); // Colors.blue[900]
  static const Color filterButtonTextColor = Colors.white;

  // Category Filter Dialog styles
  static const Color dialogBgColor = Colors.white;
  static const Color dialogHeaderColor = Color(0xFF1976D2); // Colors.blue[700]
  static const Color dialogHeaderTextColor = Colors.white;
  static const Color categoryChipBgColor =
      Color(0xFFE3F2FD); // Colors.blue.shade50
  static const Color categoryChipSelectedBgColor =
      Color(0xFF2196F3); // Colors.blue
  static const Color categoryChipBorderColor =
      Color(0xFF90CAF9); // Colors.blue.shade200
  static const Color categoryChipSelectedBorderColor =
      Color(0xFF1976D2); // Colors.blue.shade700
  static const Color categoryChipTextColor =
      Color(0xFF1976D2); // Colors.blue.shade700
  static const Color categoryChipSelectedTextColor = Colors.white;
  static const Color dialogActionButtonBgColor =
      Color(0xFF1976D2); // Colors.blue[700]
  static const Color dialogActionButtonTextColor = Colors.white;
  static const Color dialogClearButtonBgColor = Colors.white;
  static const Color dialogClearButtonTextColor = Colors.red;
  static const Color dialogClearButtonBorderColor = Colors.red;

  static const TextStyle dialogTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: dialogHeaderTextColor,
  );

  static const TextStyle categoryChipTextStyle = TextStyle(
    fontSize: 14,
    color: categoryChipTextColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle categoryChipSelectedTextStyle = TextStyle(
    fontSize: 14,
    color: categoryChipSelectedTextColor,
    fontWeight: FontWeight.w600,
  );

  static ButtonStyle filterActionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: dialogActionButtonBgColor,
    foregroundColor: dialogActionButtonTextColor,
    elevation: 2,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.standardPadding,
      vertical: AppDimensions.buttonHeight,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle clearFilterButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: dialogClearButtonTextColor,
    side: BorderSide(color: dialogClearButtonBorderColor),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.standardPadding,
      vertical: AppDimensions.buttonHeight,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static BoxDecoration categoryFilterChipDecoration = BoxDecoration(
    color: categoryChipBgColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: categoryChipBorderColor),
  );

  static BoxDecoration categoryChipSelectedDecoration = BoxDecoration(
    color: categoryChipSelectedBgColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: categoryChipSelectedBorderColor),
  );

  static ButtonStyle courseScreenFilterButtonStyle(bool isSelected) =>
      ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? filterButtonSelectedColor : filterButtonBgColor,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  // Theme và Language Settings Styles
  // Light Theme Colors
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightPrimaryColor = Colors.orange;
  static const Color lightTextColor = Colors.black;
  static const Color lightTextSecondaryColor = Colors.black87;
  static const Color lightDividerColor = Color(0xFFEEEEEE);
  static const Color lightIconColor = Color(0xFF757575);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1F1F1F);
  static const Color darkPrimaryColor = Colors.orange;
  static const Color darkTextColor = Colors.white;
  static const Color darkTextSecondaryColor = Colors.white70;
  static const Color darkDividerColor = Color(0xFF424242);
  static const Color darkIconColor = Color(0xFFBDBDBD);

  // Theme Settings Styles
  static const TextStyle themeTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle themeOptionTextStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle themeDescriptionTextStyle = TextStyle(
    fontSize: 12,
  );

  static BoxDecoration themeCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.05),
        spreadRadius: 1,
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Language Settings Styles
  static const TextStyle languageTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle languageOptionTextStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle languageFlagStyle = TextStyle(
    fontSize: 24,
  );

  static const TextStyle languageDescriptionStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static BoxDecoration languageExampleDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
  );

  static BoxDecoration languageHeaderDecoration(Color primaryColor) => BoxDecoration(
    color: primaryColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    ),
  );

  // Settings Screen Styles
  static BoxDecoration settingItemDecoration(bool isHighlighted, Color primaryColor, Color cardColor) => BoxDecoration(
    color: isHighlighted ? primaryColor.withOpacity(0.05) : cardColor,
    border: Border(
      bottom: BorderSide(
        color: Colors.grey.shade200,
        width: 1,
      ),
    ),
  );

  static const TextStyle settingItemTextStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle settingSectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static ButtonStyle logoutButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  static ButtonStyle cancelButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    side: const BorderSide(color: Colors.grey),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // Dialog Styles
  static BoxDecoration dialogDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration dialogIconDecoration = BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    shape: BoxShape.circle,
  );

  static const TextStyle dialogTitleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogContentTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}
