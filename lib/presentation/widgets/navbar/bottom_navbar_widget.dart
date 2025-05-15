import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_list.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {required this.selectedIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Màu đổ bóng nhẹ
            blurRadius: 5, // Mức độ mờ của bóng
            spreadRadius: 2, // Độ lan của bóng
            offset: const Offset(0, -3), // Dịch chuyển bóng lên trên một chút
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex, // Chỉ mục tab hiện tại
        items: _buildNavBarItems(), // Hàm trả về danh sách các item
        selectedItemColor: Colors.lightBlue, // Màu xanh lá khi được chọn
        unselectedItemColor: const Color.fromARGB(
            255, 105, 105, 105), // Màu đen khi không được chọn
        showUnselectedLabels: true,
        onTap: (index) {
          // Gọi callback onTap cho tất cả các tab, bao gồm cả tab "Đề thi"
          onTap(index);
        },
        backgroundColor: Colors.white, // Đảm bảo màu nền trắng
      ),
    );
  }

  // Hàm tạo danh sách các BottomNavigationBarItem
  List<BottomNavigationBarItem> _buildNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home, size: selectedIndex == 0 ? 28 : 24),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book, size: selectedIndex == 1 ? 28 : 24),
        label: 'Tài liệu',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.golf_course, size: selectedIndex == 2 ? 28 : 24),
        label: 'Khoá học',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.quiz_outlined, size: selectedIndex == 3 ? 28 : 24),
        label: 'Đề thi',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, size: selectedIndex == 4 ? 28 : 24),
        label: 'Tài khoản',
      ),
    ];
  }
}
