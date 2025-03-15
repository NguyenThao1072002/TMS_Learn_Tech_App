import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/screens/login/login.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      // Nếu đã chọn "Ghi nhớ đăng nhập" thì chỉ cần xóa token
      await prefs.remove('jwt');
      await prefs.remove('refreshToken');
    } else {
      // Xóa toàn bộ dữ liệu đăng nhập
      await prefs.clear();
    }

    // Hiển thị thông báo đăng xuất thành công
    Fluttertoast.showToast(
      msg: "Đăng xuất thành công!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );

    // Chuyển về màn hình đăng nhập & xóa lịch sử trang
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Đổ bóng nhẹ
        centerTitle: true, // Tiêu đề nằm giữa
        title: Text(
          "Cài đặt",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Xong",
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nhóm: Tài khoản
                  _buildSectionTitle("Tài khoản"),
                  _buildSettingItem("Cập nhật thông tin tài khoản"),
                  _buildSettingItem("Đổi mật khẩu"),
                  _buildSettingItem("Thông báo"),

                  SizedBox(height: 16),

                  // Nhóm: Nâng cấp tài khoản
                  _buildSectionTitle("Nâng cấp tài khoản"),
                  _buildSettingItem("Gói thành viên"),

                  SizedBox(height: 16),

                  // Nhóm: Hỗ trợ
                  _buildSectionTitle("Hỗ trợ"),
                  _buildSettingItem("Trung tâm trợ giúp"),
                ],
              ),
            ),
          ),

          // Nút Đăng xuất với khoảng cách từ dưới
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _logout(context), // Gọi hàm đăng xuất
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor:
                        Colors.black.withOpacity(0.5), // Hiệu ứng đổ bóng
                    elevation: 6,
                  ),
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
//),

                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.blue,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(30),
                  //   ),
                  //   shadowColor: Colors.black.withOpacity(0.5),
                  //   elevation: 6, // Độ cao bóng
                  // ),
                  // child: Text(
                  //   "Đăng xuất",
                  //   style: TextStyle(fontSize: 16, color: Colors.white),
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tiêu đề nhóm cài đặt
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  // Widget mục cài đặt
  Widget _buildSettingItem(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 239, 238, 238)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
