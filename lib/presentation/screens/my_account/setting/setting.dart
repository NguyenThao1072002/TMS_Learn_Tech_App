import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/domain/usecases/login_usecase.dart';
import 'package:tms_app/presentation/controller/login/login_controller.dart';
import 'package:tms_app/presentation/controller/theme_controller.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';
import 'package:tms_app/presentation/screens/my_account/setting/change_password.dart';
import 'package:tms_app/presentation/screens/my_account/setting/notification.dart';
import 'package:tms_app/presentation/screens/my_account/setting/update_account.dart';
import 'package:tms_app/presentation/screens/my_account/setting/help_and_support.dart';
import 'package:tms_app/presentation/screens/my_account/setting/member.dart';
import 'package:tms_app/presentation/screens/my_account/setting/appearance_language_screen.dart';
import 'package:tms_app/core/localization/app_localization.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late LoginController _loginController;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Khởi tạo LoginController
    final loginUseCase = GetIt.instance<LoginUseCase>();
    _loginController = LoginController(loginUseCase: loginUseCase);

    // Bắt đầu animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
          context.tr('settings'),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              context.tr('done'),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context.tr('accountSettings')),
                _buildAnimatedSettingItem(
                  context.tr('updateAccount'),
                  icon: Icons.person,
                  delay: 100,
                  onTap: () {
                    // Điều hướng đến màn hình cập nhật thông tin tài khoản
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateAccountScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedSettingItem(
                  context.tr('changePassword'),
                  icon: Icons.lock,
                  delay: 200,
                  onTap: () {
                    // Điều hướng đến màn hình đổi mật khẩu
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedSettingItem(
                  context.tr('notifications'),
                  icon: Icons.notifications,
                  delay: 300,
                  onTap: () {
                    // Điều hướng đến màn hình cài đặt thông báo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                
                _buildAnimatedSettingItem(
                  context.tr('appearanceAndLanguage'),
                  icon: Icons.language_outlined,
                  delay: 350,
                  onTap: () {
                    // Điều hướng đến màn hình giao diện & ngôn ngữ
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppearanceAndLanguageScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),

                _buildSectionTitle(context.tr('upgradeAccount')),
                _buildAnimatedSettingItem(
                  context.tr('upgradeAccount'),
                  icon: Icons.workspace_premium,
                  delay: 400,
                  isHighlighted: true,
                  onTap: () {
                    // Điều hướng đến màn hình đăng ký gói thành viên
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembershipScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),

                _buildSectionTitle(context.tr('support')),
                _buildAnimatedSettingItem(
                  context.tr('helpCenter'),
                  icon: Icons.help_outline,
                  delay: 500,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedSettingItem(
                  context.tr('contactUs'),
                  icon: Icons.phone_outlined,
                  delay: 600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedSettingItem(
                  context.tr('reportIssue'),
                  icon: Icons.bug_report_outlined,
                  delay: 700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),

                // Nút đăng xuất với hiệu ứng ripple
                _buildAnimatedLogoutButton(800),

                // Phần thông tin phiên bản
                _buildAnimatedVersionInfo(900),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
    );
  }

  // Widget hiển thị item cài đặt với animation
  Widget _buildAnimatedSettingItem(
    String title, {
    required IconData icon,
    required int delay,
    required VoidCallback onTap,
    bool isHighlighted = false,
    required bool isDarkMode,
  }) {
    // Màu đường kẻ tùy theo chế độ sáng/tối
    final dividerColor = isDarkMode 
        ? Colors.grey.shade600 // Màu xám trắng cho chế độ tối
        : Colors.grey.shade300; // Màu xám đậm cho chế độ sáng
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final startTime = delay / 1000 < 1.0 ? delay / 1000 : 0.9;
        final endTime = (startTime + 0.1) < 1.0 ? (startTime + 0.1) : 1.0;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(startTime, endTime, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(20 * (1 - animation.value), 0),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isHighlighted 
                  ? Theme.of(context).primaryColor.withOpacity(0.05) 
                  : Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: dividerColor, // Sử dụng màu đường kẻ đã định nghĩa
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isHighlighted 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget nút đăng xuất với animation
  Widget _buildAnimatedLogoutButton(int delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final startTime = delay / 1000 < 1.0 ? delay / 1000 : 0.9;
        final endTime = (startTime + 0.1) < 1.0 ? (startTime + 0.1) : 1.0;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(startTime, endTime, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  // Xử lý đăng xuất
                  _showLogoutConfirmDialog(context);
                },
                child: Text(
                  context.tr('logout'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget thông tin phiên bản với animation
  Widget _buildAnimatedVersionInfo(int delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final startTime = delay / 1000 < 1.0 ? delay / 1000 : 0.9;
        final endTime = (startTime + 0.1) < 1.0 ? (startTime + 0.1) : 1.0;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(startTime, endTime, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.tr('version'),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Hộp thoại xác nhận đăng xuất
  void _showLogoutConfirmDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon đăng xuất
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // Tiêu đề
                Text(
                  context.tr('logout'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                // Nội dung
                Text(
                  context.tr('logoutConfirmation'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 25),
                // Các nút hành động
                Row(
                  children: [
                    // Nút hủy
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: dividerColor), // Sử dụng màu divider theo chế độ
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          context.tr('cancel'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nút đăng xuất
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Xử lý đăng xuất
                          Navigator.of(context).pop(); // Đóng dialog

                          // Gọi phương thức logout của LoginController
                          _loginController.logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.tr('logout'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
