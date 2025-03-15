import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tms/screens/MyAccount/Setting/settingScreen.dart';
import 'package:tms/screens/myAccount/learning/learningResult.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileHeader(),
            const SizedBox(height: 16),
            buildOverviewSection(),
            const SizedBox(height: 20),
            buildMyCoursesSection(),
            const SizedBox(height: 30),
            buildActionButtons(),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        buildIconWithBadge(Icons.message, Colors.blue, "5"),
        buildIconWithBadge(Icons.shopping_cart_outlined, Colors.green, "3"),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingScreen()));
          },
        ),
      ],
    );
  }

  Widget buildIconWithBadge(IconData icon, Color color, String badgeText) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: () {},
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/images/login/forgotPassword.png"),
          ),
          const SizedBox(height: 8),
          const Text(
            "Thu Thảo",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "tt.1072002@gmail.com",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tổng quan",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildOverviewCard("22", "Day streaks", Icons.local_fire_department,
                Colors.orange, 0.75),
            buildOverviewCard(
                "375", "điểm", Icons.emoji_events, Colors.amber, 0.5),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildOverviewCard(
                "5", "Khoá học", Icons.menu_book, Colors.blue, 0.8),
            buildOverviewCard(
                "47", "Tài liệu", Icons.article, Colors.deepOrange, 0.6),
          ],
        ),
      ],
    );
  }

  Widget buildOverviewCard(String number, String label, IconData icon,
      Color color, double progress) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(1, 2)),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 5.0,
            percent: progress,
            center: Icon(icon, color: color, size: 28),
            progressColor: color,
            backgroundColor: Colors.grey.shade200,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 8),
          Text(number,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

   // Phần "Khoá học của tôi"
  Widget buildMyCoursesSection() {
    List<Map<String, String>> myCourses = [
      {
        "title": "Cấu trúc dữ liệu & giải thuật",
        "image": "assets/images/courses/courseExample.png"
      },
      {"title": "Trí tuệ nhân tạo", "image": "assets/images/courses/courseExample.png"},
      {"title": "Học máy nâng cao", "image": "assets/images/courses/courseExample.png"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Khoá học của tôi",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Xem thêm >>",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myCourses.length,
            itemBuilder: (context, index) {
              return buildCourseCard(myCourses[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Card khoá học
  Widget buildCourseCard(Map<String, String> course) {
    return GestureDetector(
      onTap: () {
        print("Nhấn vào khoá học: ${course['title']}");
      },
      child: Container(
        width: 200,
        height: 1700,
        margin: const EdgeInsets.only(right: 10, bottom: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset(1, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                course["image"]!,
                fit: BoxFit.cover,
                height: 80,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course["title"]!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

    /// Nút điều hướng khác
  Widget buildActionButtons() {
    return Column(
      children: [
        buildButton("Kết quả học tập", Colors.redAccent, LearningResults()),
        buildButton("Lịch sử hoạt động", Colors.blue, null),
        buildButton("Quản lý giao dịch", const Color.fromARGB(255, 88, 202, 1), null),
        buildButton("Hỗ trợ", Color.fromARGB(255, 245, 199, 129), null ),   
        ],
    );
  }

    Widget buildButton(String text, Color color, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}

//   Widget buildButton(String text, Color color) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: color.withOpacity(0.1)),
//         child: Text(text,
//             style: TextStyle(
//                 fontSize: 18, color: color, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// //}
