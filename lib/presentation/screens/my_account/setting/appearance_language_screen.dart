import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/theme_controller.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';

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
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giao diện & Ngôn ngữ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            _buildSectionTitle('Giao diện'),
            _buildThemeModeSection(themeController),
            
            // Language Section
            _buildSectionTitle('Ngôn ngữ'),
            _buildLanguageSection(languageController),
          ],
        ),
      ),
    );
  }
  
  // Widget hiển thị tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
  
  // Widget cho phần tùy chọn Theme Mode
  Widget _buildThemeModeSection(ThemeController themeController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn chế độ hiển thị giao diện ứng dụng',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // Light Mode Option
            _buildThemeOptionItem(
              title: 'Sáng',
              subtitle: 'Giao diện màu sáng cho ứng dụng',
              icon: Icons.light_mode,
              isSelected: themeController.themeMode == ThemeMode.light,
              onTap: () => themeController.setThemeMode(ThemeMode.light),
            ),
            
            const Divider(height: 1),
            
            // Dark Mode Option
            _buildThemeOptionItem(
              title: 'Tối',
              subtitle: 'Giao diện màu tối giúp giảm mỏi mắt khi sử dụng buổi tối',
              icon: Icons.dark_mode,
              isSelected: themeController.themeMode == ThemeMode.dark,
              onTap: () => themeController.setThemeMode(ThemeMode.dark),
            ),
            
            const Divider(height: 1),
            
            // System Mode Option
            _buildThemeOptionItem(
              title: 'Theo hệ thống',
              subtitle: 'Tự động thay đổi theo cài đặt của thiết bị',
              icon: Icons.brightness_auto,
              isSelected: themeController.themeMode == ThemeMode.system,
              onTap: () => themeController.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget cho phần tùy chọn Language
  Widget _buildLanguageSection(LanguageController languageController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn ngôn ngữ hiển thị',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
                    title: language['name'],
                    flag: language['flag'],
                    isSelected: isSelected,
                    onTap: () => languageController.setLanguage(language['code']),
                  ),
                  if (language != languageController.availableLanguages.last)
                    const Divider(height: 1),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
} 