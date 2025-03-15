import 'package:flutter/material.dart';
import 'package:tms/widgets/courses/myCourse.dart';
 // Import MyCourseCard

class MyCourse extends StatefulWidget {
  const MyCourse({super.key});

  @override
  _MyCourseState createState() => _MyCourseState();
}

class _MyCourseState extends State<MyCourse>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Sửa length thành 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Khoá học của tôi",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCourseList("Đã đăng ký"),
          _buildCourseList("Đang học"),
          _buildCourseList("Hoàn thành"),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      tabs: [
        _buildTabItem("Đã đăng ký", Icons.play_circle, Colors.blue),
        _buildTabItem("Đang học", Icons.notifications, Colors.orange),
        _buildTabItem("Hoàn thành", Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildTabItem(String title, IconData icon, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Flexible(
            child: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(String tab) {
    // Giả sử danh sách khóa học chung, bạn có thể lọc theo tab trong thực tế
    List<Map<String, dynamic>> courses = [
      {
        "title": "Lập trình C",
        "image": "assets/images/courses/courseExample.png",
        "progress": 1,
        "timeLeft": "6 hours left"
      },
      {
        "title": "Cấu trúc dữ liệu & giải thuật",
        "image": "assets/images/courses/courseExample.png",
        "progress": 40,
        "timeLeft": "4 hours left"
      },
      {
        "title": "Lập trình C",
        "image": "assets/images/courses/courseExample.png",
        "progress": 60,
        "timeLeft": "6 hours left"
      },
      {
        "title": "Lập trình C",
        "image": "assets/images/courses/courseExample.png",
        "progress": 2,
        "timeLeft": "6 hours left"
      },
      {
        "title": "Lập trình C",
        "image": "assets/images/courses/courseExample.png",
        "progress": 0,
        "timeLeft": "6 hours left"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return MyCourseCard(
          courseTitle: course["title"],
          courseImage: course["image"],
          progress: course["progress"].toDouble(),
          timeLeft: course["timeLeft"],
          onTap: () {
            // Điều hướng đến màn hình chi tiết khóa học
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.play_circle), label: "Khoá học"),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: "Bài viết"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: "Về chúng tôi"),
      ],
    );
  }
}
