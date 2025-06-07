import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/theme_controller.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';
import 'package:tms_app/core/localization/app_localization.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class AppearanceAndLanguageScreen extends StatefulWidget {
  const AppearanceAndLanguageScreen({Key? key}) : super(key: key);

  @override
  State<AppearanceAndLanguageScreen> createState() => _AppearanceAndLanguageScreenState();
}

class _AppearanceAndLanguageScreenState extends State<AppearanceAndLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final languageController = Provider.of<LanguageController>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          context.tr('appearanceAndLanguage'),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            color: Theme.of(context).appBarTheme.iconTheme?.color
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            _buildSectionTitle(context.tr('appearance')),
            _buildThemeModeSection(themeController, context, isDarkMode),
            
            // Language Section
            _buildSectionTitle(context.tr('language')),
            _buildLanguageSection(languageController, context, isDarkMode),
          ],
        ),
      ),
    );
  }
  
  // Widget hiển thị tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.settingCardMarginHorizontal, 
        top: AppDimensions.settingCardMarginVertical * 2, 
        bottom: AppDimensions.settingCardMarginVertical
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppDimensions.settingSectionTitleFontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
    );
  }
  
  // Widget cho phần tùy chọn Theme Mode
  Widget _buildThemeModeSection(ThemeController themeController, BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.settingCardMarginHorizontal, 
        vertical: AppDimensions.settingCardMarginVertical
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.settingCardBorderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.settingCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('selectThemeMode'),
              style: TextStyle(
                fontSize: AppDimensions.settingDescriptionFontSize,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            
            // Light Mode Option
            _buildThemeOptionItem(
              title: context.tr('lightTheme'),
              subtitle: context.tr('lightThemeDescription'),
              icon: Icons.light_mode,
              isSelected: themeController.themeMode == ThemeMode.light,
              onTap: () => themeController.setThemeMode(ThemeMode.light),
              isDarkMode: isDarkMode,
            ),
            
            Divider(height: 1, color: Theme.of(context).dividerColor),
            
            // Dark Mode Option
            _buildThemeOptionItem(
              title: context.tr('darkTheme'),
              subtitle: context.tr('darkThemeDescription'),
              icon: Icons.dark_mode,
              isSelected: themeController.themeMode == ThemeMode.dark,
              onTap: () => themeController.setThemeMode(ThemeMode.dark),
              isDarkMode: isDarkMode,
            ),
            
            Divider(height: 1, color: Theme.of(context).dividerColor),
            
            // System Mode Option
            _buildThemeOptionItem(
              title: context.tr('systemTheme'),
              subtitle: context.tr('systemThemeDescription'),
              icon: Icons.brightness_auto,
              isSelected: themeController.themeMode == ThemeMode.system,
              onTap: () => themeController.setThemeMode(ThemeMode.system),
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget cho phần tùy chọn Language
  Widget _buildLanguageSection(LanguageController languageController, BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.settingCardMarginHorizontal, 
        vertical: AppDimensions.settingCardMarginVertical
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.settingCardBorderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.settingCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('selectAppLanguage'),
              style: TextStyle(
                fontSize: AppDimensions.settingDescriptionFontSize,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tạo các tùy chọn ngôn ngữ từ danh sách có sẵn
            ...languageController.availableLanguages.map((language) {
              final bool isSelected = 
                  languageController.currentLocale.languageCode == language['code'];
              
              return Column(
                children: [
                  _buildLanguageOptionItem(
                    title: language['name'] as String,
                    flag: language['flag'] as String,
                    isSelected: isSelected,
                    onTap: () => languageController.setLanguage(language['code'] as String),
                    isDarkMode: isDarkMode,
                  ),
                  if (language != languageController.availableLanguages.last)
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  // Widget hiển thị mỗi tùy chọn giao diện
  Widget _buildThemeOptionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final primaryColor = isDarkMode ? AppStyles.darkPrimaryColor : AppStyles.lightPrimaryColor;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.settingItemVerticalPadding),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              size: AppDimensions.settingItemIconSize,
            ),
            const SizedBox(width: AppDimensions.settingItemSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppDimensions.settingTitleFontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.settingDescriptionSpacing),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppDimensions.settingDescriptionFontSize,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: AppDimensions.settingItemIconSize,
              ),
          ],
        ),
      ),
    );
  }
  
  // Widget hiển thị mỗi tùy chọn ngôn ngữ
  Widget _buildLanguageOptionItem({
    required String title,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final primaryColor = isDarkMode ? AppStyles.darkPrimaryColor : AppStyles.lightPrimaryColor;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.settingItemVerticalPadding),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: AppDimensions.settingFlagFontSize),
            ),
            const SizedBox(width: AppDimensions.settingItemSpacing),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.settingTitleFontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: AppDimensions.settingItemIconSize,
              ),
          ],
        ),
      ),
    );
  }
} 