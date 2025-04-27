import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tms_app/presentation/screens/homePage/about_us.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  // Định nghĩa các thông tin liên hệ
  static const String facebookUrl = 'https://www.facebook.com/ha.nam.213230';
  static const String zaloNumber = '0348740942';
  static const String emailAddress = 'tms.huit@gmail.com';
  static const String websiteUrl = 'http://tmslearntech.io.vn/';

  // Phương thức để mở liên kết
  void _openLink(BuildContext context, String type, String value) {
    try {
      // Hiển thị dialog xác nhận
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mở liên kết'),
          content: Text('Bạn muốn mở: $value?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _processLink(context, type, value);
              },
              child: const Text('Mở'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError(context, 'Không thể xử lý: $value');
    }
  }

  // Xử lý loại liên kết và mở
  void _processLink(BuildContext context, String type, String value) {
    try {
      switch (type.toLowerCase()) {
        case 'facebook':
          // Thử mở ứng dụng Facebook trước, sau đó mở trình duyệt nếu không được
          _launchExternalApp(context, 'fb://profile/ha.nam.213230', value);
          break;
        case 'zalo':
          // Mở ứng dụng Zalo với số điện thoại
          _launchExternalApp(context, 'https://zalo.me/$value', 'Zalo: $value');
          break;
        case 'email':
          // Mở ứng dụng email
          _launchEmailApp(context, value);
          break;
        case 'website':
          // Mở website trong trình duyệt
          _launchExternalApp(context, value, 'Website');
          break;
        default:
          _launchExternalApp(context, value, 'Liên kết');
      }
    } catch (e) {
      _showError(context, 'Lỗi xử lý liên kết: ${e.toString()}');
    }
  }

  // Mở ứng dụng email
  Future<void> _launchEmailApp(BuildContext context, String email) async {
    try {
      final Uri emailUri = Uri.parse('mailto:$email');
      await launchUrl(emailUri);
      _showSuccess(context, 'Đang mở ứng dụng email');
    } catch (e) {
      _showError(context, 'Không thể mở ứng dụng email');
    }
  }

  // Mở URL trong trình duyệt bên ngoài hoặc ứng dụng tương ứng
  Future<void> _launchExternalApp(
      BuildContext context, String url, String label) async {
    try {
      final Uri uri = Uri.parse(url);
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        _showSuccess(context, 'Đang mở $label');
      } else {
        _showError(context, 'Không thể mở $label');
      }
    } catch (e) {
      _showError(context, 'Không thể mở $label: ${e.toString()}');
    }
  }

  // Copy text vào clipboard
  void _copyToClipboard(BuildContext context, String text, String label) {
    // Flutter cần import package:flutter/services.dart để dùng Clipboard
    // Thay vì thực hiện copy, hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn $label: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hiển thị thông báo lỗi
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hiển thị thông báo thành công
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF2C3E50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo và thông tin công ty
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF2C3E50),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'TMS Learning',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Nền tảng học tập trực tuyến hàng đầu với các khóa học chất lượng cao từ các chuyên gia.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Thông tin liên hệ kết hợp với biểu tượng
                    _buildContactRow(
                        context, Icons.facebook, 'Facebook', facebookUrl),
                    const SizedBox(height: 8),
                    _buildContactRow(context, Icons.phone, 'Zalo', zaloNumber),
                    const SizedBox(height: 8),
                    _buildContactRow(
                        context, Icons.email, 'Email', emailAddress),
                    const SizedBox(height: 8),
                    _buildContactRow(
                        context, Icons.language, 'Website', websiteUrl),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Danh mục và liên kết
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liên kết hữu ích',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFooterLink('Trang chủ'),
                    _buildFooterLink('Khóa học'),
                    _buildFooterLink('Tài liệu'),
                    _buildFooterLink('Blog'),
                    _buildFooterLink('Liên hệ'),
                    _buildFooterLink('Về TMS'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          const Text(
            '© 2025 TMS Learn Tech. Bảo lưu mọi quyền.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
      BuildContext context, IconData icon, String label, String value) {
    return InkWell(
      onTap: () => _openLink(context, label, value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title) {
    return Builder(builder: (BuildContext context) {
      return InkWell(
        onTap: () {
          if (title == 'Về TMS') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
          }
          // Có thể thêm điều hướng khác cho các title khác trong tương lai
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    });
  }
}
