import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/widgets/course/my_course.dart';
import 'package:tms_app/presentation/screens/my_account/setting/setting.dart';
import 'package:tms_app/presentation/screens/my_account/overview/streak.dart';
import 'package:tms_app/presentation/screens/my_account/my_wallet/my_wallet.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/my_course.dart';
import 'dart:async';
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart';
import 'package:tms_app/presentation/screens/my_account/learning_result/learning_result.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/activate_course.dart';
import 'package:tms_app/presentation/screens/my_account/overview/rank.dart';
import 'package:tms_app/presentation/screens/my_account/chat.dart';
// import 'package:tms_app/core/app_export.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                widget.color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: widget.color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountOverviewScreen extends StatefulWidget {
  const AccountOverviewScreen({Key? key}) : super(key: key);

  @override
  State<AccountOverviewScreen> createState() => _AccountOverviewScreenState();
}

class _AccountOverviewScreenState extends State<AccountOverviewScreen>
    with SingleTickerProviderStateMixin {
  // Theme colors
  final Color primaryColor = Colors.orange;
  final Color accentColor = Colors.deepOrange;
  final Color blueColor = Colors.blue;
  final Color gray600 = Colors.grey.shade600;
  final Color purpleColor = Colors.purple;

  // Text styles
  TextStyle get titleLarge =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  TextStyle get bodyMedium => const TextStyle(fontSize: 14);

  late TabController _tabController;
  late CourseController _courseController;
  late AnimationController _colorAnimationController;
  late Timer _colorTimer;
  int _colorIndex = 0;

  // Danh sách màu gradient để animation
  final List<List<Color>> _gradientColorSets = [
    [Colors.orange, Colors.deepOrange],
    [Colors.deepOrange, Colors.orangeAccent],
    [Colors.orangeAccent, Colors.amber],
    [Colors.amber, Colors.orange],
  ];

  List<Color> get _currentGradientColors => _gradientColorSets[_colorIndex];

  final CourseUseCase _courseUseCase = GetIt.instance<CourseUseCase>();
  List<CourseCardModel> _myCourses = [];
  bool _isLoading = true;
  int _dayStreaks = 15;

  // Dữ liệu mẫu
  final String _userName = "Thu Thảo";
  final String _userEmail = "tt.1072002@gmail.com";
  final String _userAvatar =
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop";

  // Số liệu tổng quan
  final int _totalPoints = 375;
  final int _totalCourses = 5;
  final int _totalDocuments = 47;

  // Số lượng cho badges
  final int _cartItemCount = 3;
  final int _unreadMessageCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo CourseController và tải khóa học
    _courseController = CourseController(_courseUseCase);
    _loadMyCourses();

    // Khởi tạo timer cho hiệu ứng màu chạy
    _colorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _colorIndex = (_colorIndex + 1) % _gradientColorSets.length;
      });
    });
  }

  Future<void> _loadMyCourses() async {
    setState(() {
      _isLoading = true;
    });

    await _courseController.loadCourses();
    // Lấy 2 khóa học đầu tiên từ danh sách
    setState(() {
      _myCourses = _courseController.filteredCourses.value.take(2).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _courseController.dispose();
    _colorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          // Kích hoạt khóa học
          IconButton(
            icon: const Icon(Icons.key, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivateCourseScreen(),
                ),
              );
            },
          ),
          //giỏ hàng
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          //chat
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              if (_unreadMessageCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadMessageCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Widget cài đặt
          Hero(
            tag: 'settings-icon',
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần thông tin người dùng và avatar
              _buildUserInfoSection(),

              // Phần tổng quan số liệu
              _buildOverviewSection(),

              // Ví của tôi (My Wallet)
              _buildWalletSection(),

              // Khóa học của tôi
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: () => _navigateToMyCourses(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: blueColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Khóa học của tôi",
                                      style: titleLarge.copyWith(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    _navigateToMyCourses();
                                  },
                                  child: const Text("Xem thêm"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Danh sách khóa học có thể nhấn để điều hướng
                            MyCourses(courses: _myCourses),
                          ],
                        ),
                      ),
              ),

              // Kết quả học tập
              _buildLearningOutcomesSection(),

              // Lịch sử hoạt động
              _buildActivityHistorySection(),

              // Lịch sử thanh toán
              _buildPaymentHistorySection(),

              // Hỗ trợ
              _buildSupportSection(),

              // Thanh điều hướng dưới cùng (đã có trong bottom navigation bar)
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thông tin người dùng với avatar
  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(_userAvatar),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          // Thông tin người dùng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị các số liệu thống kê
  Widget _buildOverviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24,
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Tổng quan",
                style: titleLarge.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                title: "Day Streaks",
                value: _dayStreaks.toString(),
                icon: Icons.local_fire_department,
                color: primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StreakScreen(currentStreak: _dayStreaks),
                    ),
                  );
                },
              ),
              _buildStatCard(
                title: "Điểm",
                value: "250",
                icon: Icons.star,
                color: accentColor,
                onTap: () {
                  _navigateToRank();
                },
              ),
              _buildStatCard(
                title: "Khoá học",
                value: "4",
                icon: Icons.school,
                color: blueColor,
                onTap: () {
                  _navigateToMyCourses();
                },
              ),
              _buildStatCard(
                title: "Tài liệu",
                value: "12",
                icon: Icons.description,
                color: purpleColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return StatCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }

  // Widget hiển thị kết quả học tập
  Widget _buildLearningOutcomesSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Màu pastel đỏ nhạt
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LearningResultScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kết quả học tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị lịch sử hoạt động
  Widget _buildActivityHistorySection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF9C4), // Màu pastel vàng nhạt phù hợp với màu cam
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Lịch sử hoạt động',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 252, 175, 9),
        ),
      ),
    );
  }

  // Widget hiển thị lịch sử thanh toán và giỏ hàng
  Widget _buildPaymentHistorySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Điều hướng đến trang giỏ hàng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD), // Màu pastel xanh dương nhạt
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giỏ hàng & Thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 9, 94, 252),
                    ),
                  ),
                  if (_cartItemCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_cartItemCount sản phẩm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _cartItemCount > 0
                    ? 'Bạn có $_cartItemCount sản phẩm trong giỏ hàng. Nhấn để thanh toán ngay!'
                    : 'Xem lịch sử thanh toán và quản lý giỏ hàng của bạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hỗ trợ
  Widget _buildSupportSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Màu pastel tím nhạt
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Hỗ trợ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 207, 9, 252),
        ),
      ),
    );
  }

  // Widget hiển thị ví của tôi
  Widget _buildWalletSection() {
    final double balance = 500000; // 500,000 VND

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyWalletScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ví của tôi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Số dư:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(balance / 1000).toStringAsFixed(0)}K VND',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFF3498DB),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Nạp tiền',
                              style: TextStyle(
                                color: Color(0xFF3498DB),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMyCourses() {
    // Chuyển đến màn hình Khóa học của tôi với hiệu ứng hero
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyCourseScreen(),
      ),
    );
  }

  void _navigateToRank() {
    // Chuyển đến màn hình Rank với hiệu ứng hero
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankScreen(),
      ),
    );
  }
}
