import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {required this.selectedIndex, required this.onTap, Key? key})
      : super(key: key);

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
            offset: Offset(0, -3), // Dịch chuyển bóng lên trên một chút
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: selectedIndex == 0 ? 30 : 24),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: selectedIndex == 1 ? 30 : 24),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.golf_course, size: selectedIndex == 2 ? 30 : 24),
            label: 'Khoá học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: selectedIndex == 3 ? 30 : 24),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: selectedIndex == 4 ? 30 : 24),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue, // Màu xanh khi được chọn
        unselectedItemColor: const Color.fromARGB(255, 105, 105, 105), // Màu đen khi không được chọn
        showUnselectedLabels: true,
        onTap: onTap,
        backgroundColor: Colors.white, // Đảm bảo màu nền trắng
      ),
    );
  }
}
