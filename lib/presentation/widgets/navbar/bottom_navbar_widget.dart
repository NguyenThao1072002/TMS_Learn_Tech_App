import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_list.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {required this.selectedIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3) 
        : Colors.black.withOpacity(0.1);
    final selectedItemColor = Colors.lightBlue;
    final unselectedItemColor = isDarkMode 
        ? Colors.grey.shade400 
        : const Color.fromARGB(255, 105, 105, 105);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        items: _buildNavBarItems(),
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        showUnselectedLabels: true,
        onTap: (index) {
          onTap(index);
        },
        backgroundColor: backgroundColor,
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
