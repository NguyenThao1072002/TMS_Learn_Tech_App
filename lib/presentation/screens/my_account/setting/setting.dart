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
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Xong',
              style: TextStyle(
                color: Colors.blue,
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
                _buildSectionTitle('Tài khoản'),
                _buildAnimatedSettingItem(
                  'Cập nhật thông tin tài khoản',
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
                ),
                _buildAnimatedSettingItem(
                  'Đổi mật khẩu',
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
                ),
                _buildAnimatedSettingItem(
                  'Thông báo',
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
                ),
                
                _buildAnimatedSettingItem(
                  'Giao diện & Ngôn ngữ',
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
                ),

                _buildSectionTitle('Nâng cấp tài khoản'),
                _buildAnimatedSettingItem(
                  'Nâng cấp tài khoản',
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
                ),

                _buildSectionTitle('Hỗ trợ'),
                _buildAnimatedSettingItem(
                  'Trung tâm trợ giúp',
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
                ),
                _buildAnimatedSettingItem(
                  'Liên hệ với chúng tôi',
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
                ),
                _buildAnimatedSettingItem(
                  'Báo cáo sự cố',
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
  }) {
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
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:
                  isHighlighted ? Colors.blue.withOpacity(0.05) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isHighlighted ? Colors.blue : Colors.grey.shade700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight:
                          isHighlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
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
                  backgroundColor: const Color(0xFF3B82F6),
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
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
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
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Phiên bản 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
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
                const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Nội dung
                const Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
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
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(
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
