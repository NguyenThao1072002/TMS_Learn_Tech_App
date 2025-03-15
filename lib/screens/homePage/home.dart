import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/screens/Login/login.dart';
import 'package:tms/screens/MyAccount/myAccount.dart';
import 'package:tms/screens/notifications/notificationScreen.dart';
import 'package:tms/widgets/courses/newCourseInHome.dart';
import 'package:tms/widgets/Courses/popularCourse.dart';
import 'package:tms/widgets/banner&advertise/bannerSlider.dart';
import 'package:tms/widgets/blogs/blogListInHome.dart';
import 'package:tms/widgets/courses/courseCategories.dart';
import 'package:tms/widgets/navbar/bottomNavbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   @override
  void initState() {
    super.initState();
    _checkToken();
  }
  
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePage(), // Trang chủ
    PopularCourses(), // Trang khóa học
    MyAccountScreen(), 
     NotificationScreen(), 
      MyAccountScreen(), // Trang cá nhân
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // Không có token -> Quay về màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(15), // Giảm chiều cao AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex], // Hiển thị nội dung dựa trên chỉ mục
     bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, // Sửa tên tham số
        onTap: _onItemTapped,
      ),

    );
  }
}

// Nội dung Trang chủ (HomePage)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BannerSlider(),
          SizedBox(height: 12),
          CourseCategory(),
          NewCourses(),
          SizedBox(height: 12),
          PopularCourses(),
          SizedBox(height: 12),
          BlogList(),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
