import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/account/user_update_model.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/controller/day_streak_controller.dart';
import 'package:tms_app/presentation/screens/my_account/setting/setting.dart';
import 'package:tms_app/presentation/screens/my_account/overview/streak.dart';
import 'package:tms_app/presentation/screens/my_account/my_wallet/my_wallet.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/my_course.dart';
import 'dart:async';
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart';
import 'package:tms_app/presentation/screens/my_account/learning_result/learning_result.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/activate_course.dart';
import 'package:tms_app/presentation/screens/my_account/overview/rank.dart';
import 'package:tms_app/presentation/screens/my_account/my_test/my_test_list.dart';
import 'package:tms_app/presentation/screens/my_account/chat.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/domain/usecases/overview_my_account_usecase.dart';
import 'package:tms_app/data/models/account/overview_my_account_model.dart';
import 'package:tms_app/core/lifecycle_observer.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/services/cart/cart_service.dart';
import 'package:tms_app/presentation/screens/my_account/payment/payment_history_screen.dart';
import 'package:tms_app/presentation/screens/my_account/setting/help_and_support.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
            color: isDarkMode 
                ? Color(0xFF252525).withOpacity(0.9) 
                : widget.color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.3) 
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              if (!isDarkMode)
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                ),
            ],
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
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
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

  // Thông tin người dùng
  String _userName = "";
  String _userEmail = "";
  String _userAvatar = "";
  bool _isLoadingUserInfo = true;
  String? _errorLoadingUser;

  // Account overview data
  AccountOverviewModel? _accountOverview;
  bool _isLoadingOverview = true;
  String? _errorLoadingOverview;

  // Day streak controller
  late DayStreakController _dayStreakController;
  bool _isLoadingDayStreak = true;

  // Số liệu tổng quan (will be replaced with API data)
  int _totalPoints = 0;
  int _dayStreaks = 0;
  int _totalCourses = 0;
  int _totalDocument = 0;
  double _balanceWallet = 0.0;
  int _walletId = 0;
  // Số lượng cho badges
  int _cartItemCount = 0;
  final int _unreadMessageCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo CourseController và tải khóa học
    _courseController = CourseController(_courseUseCase);
    _loadMyCourses();

    // Khởi tạo DayStreakController
    _dayStreakController = GetIt.instance<DayStreakController>();

    // Tải thông tin người dùng
    _loadUserInfo();

    // Tải account overview
    _loadAccountOverview();

    // Tải day streak
    _loadDayStreak();

    // Tải số lượng item trong giỏ hàng
    _loadCartItemCount();

    // Khởi tạo timer cho hiệu ứng màu chạy
    _colorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _colorIndex = (_colorIndex + 1) % _gradientColorSets.length;
      });
    });

    // Đăng ký lắng nghe sự kiện để reload khi mở ứng dụng từ background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final observer = LifecycleObserver(
        onResume: () {
          debugPrint('Ứng dụng tiếp tục hoạt động, kiểm tra dữ liệu...');
          _reloadDataIfNeeded();
        },
      );
      WidgetsBinding.instance.addObserver(observer);
    });
  }

  // Tải day streak từ API
  Future<void> _loadDayStreak() async {
    try {
      setState(() {
        _isLoadingDayStreak = true;
      });

      await _dayStreakController.loadDayStreak();

      setState(() {
        _dayStreaks = _dayStreakController.currentStreak;
        _isLoadingDayStreak = false;
      });

      debugPrint('Đã tải day streak thành công: $_dayStreaks');
    } catch (e) {
      setState(() {
        _isLoadingDayStreak = false;
      });
      debugPrint('Lỗi khi tải day streak: $e');
    }
  }

  // Tải thông tin người dùng từ API
  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        _isLoadingUserInfo = true;
        _errorLoadingUser = null;
      });

      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      
      // Thêm debug log để kiểm tra userId
      debugPrint('Loading user info for userId: $userId');

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorLoadingUser = "Không tìm thấy thông tin người dùng";
          _isLoadingUserInfo = false;
          _userName = 'Người dùng'; // Set default name when userId is missing
        });
        debugPrint('User ID is missing, setting default name');
        return;
      }

      // Lấy thông tin người dùng từ repository
      final accountRepository = sl<AccountRepository>();
      final userProfile = await accountRepository.getUserById(userId);

      // Debug log user profile
      debugPrint('Received user profile: fullname=${userProfile.fullname}, email=${userProfile.email}');

      // Cập nhật thông tin người dùng
      setState(() {
        _userName = userProfile.fullname ?? 'Người dùng';
        _userEmail = userProfile.email ?? '';
        _userAvatar = userProfile.image ?? '';
        _isLoadingUserInfo = false;
      });

      // In thông tin ra console để debug
      debugPrint(
          'Đã tải thông tin người dùng: $_userName, Avatar: $_userAvatar');
    } catch (e) {
      setState(() {
        _errorLoadingUser = "Lỗi khi tải thông tin người dùng: $e";
        _isLoadingUserInfo = false;
        _userName = 'Người dùng'; // Fallback name when error occurs
      });
      debugPrint('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  // Tải account overview từ API
  Future<void> _loadAccountOverview() async {
    try {
      setState(() {
        _isLoadingOverview = true;
        _errorLoadingOverview = null;
      });

      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      final token = prefs.getString('jwt');

      // Debug info
      debugPrint('Loading account overview for userId: $userId');
      debugPrint('Current JWT token: ${token?.substring(0, 20)}...');

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorLoadingOverview = "Không tìm thấy thông tin người dùng";
          _isLoadingOverview = false;
        });
        return;
      }

      // Lấy thông tin overview từ repository
      final accountRepository = sl<AccountRepository>();
      final overviewData = await accountRepository.getAccountOverview(userId);

      // Cập nhật thông tin overview
      setState(() {
        _accountOverview = overviewData;
        _totalPoints = overviewData.totalPoints;
        _dayStreaks = overviewData.dayStreak;
        _totalCourses = overviewData.countCourse;
        _totalDocument = overviewData.countDocument;
        _balanceWallet = overviewData.balanceWallet;
        _walletId = overviewData.walletId ?? 0;
        _isLoadingOverview = false;
      });

      debugPrint(
          'Đã tải account overview thành công: ${overviewData.toJson()}');
    } catch (e) {
      setState(() {
        _errorLoadingOverview = "Lỗi khi tải thông tin tổng quan: $e";
        _isLoadingOverview = false;
      });
      debugPrint('Lỗi khi tải thông tin tổng quan: $e');
    }
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

  // Tải số lượng item trong giỏ hàng
  Future<void> _loadCartItemCount() async {
    try {
      final cartService = GetIt.instance<CartService>();
      final cartItems = await cartService.getCartItems();

      setState(() {
        _cartItemCount = cartItems.length;
      });

      debugPrint('Số lượng item trong giỏ hàng: $_cartItemCount');
    } catch (e) {
      debugPrint('Lỗi khi tải số lượng item trong giỏ hàng: $e');
    }
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : const Color.fromARGB(255, 255, 255, 255);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final appBarColor = isDarkMode ? Colors.black : const Color.fromARGB(255, 255, 255, 255);
    final cardColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final cardBorderColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey.shade200;
    final shadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2);
    final iconColor = isDarkMode ? Colors.white70 : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        actions: [
          // Nút refresh để tải lại dữ liệu
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: () {
              debugPrint('Nút refresh được nhấn, tải lại dữ liệu...');
              setState(() {
                _isLoadingOverview = true;
                _isLoadingDayStreak = true;
              });
              // Xóa SharedPreferences cache nếu cần
              _clearSharedPrefsCache().then((_) {
                // Tải lại dữ liệu
                _loadUserInfo();
                _loadAccountOverview();
                _loadDayStreak();
              });
            },
          ),
          // Kích hoạt khóa học
          IconButton(
            icon: Icon(Icons.key, color: Colors.blue),
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
                icon: Icon(Icons.shopping_cart, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  ).then((_) {
                    // Cập nhật số lượng giỏ hàng khi quay lại từ màn hình giỏ hàng
                    _loadCartItemCount();
                  });
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
                icon: Icon(Icons.chat, color: Colors.green),
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
                icon: Icon(Icons.settings, color: isDarkMode ? Colors.grey.shade400 : Colors.grey),
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
              // Phần thông tin người dùng với avatar
              _buildUserInfoSection(isDarkMode, cardColor, textColor, cardBorderColor, shadowColor),

              // Phần tổng quan số liệu
              _buildOverviewSection(isDarkMode, textColor),

              // Ví của tôi (My Wallet)
              _buildWalletSection(),

              // Kết quả học tập
              _buildLearningOutcomesSection(isDarkMode, cardColor, shadowColor),

              // // Lịch sử hoạt động
              // _buildActivityHistorySection(isDarkMode, cardColor, shadowColor),

              // Lịch sử thanh toán
              _buildPaymentHistorySection(isDarkMode, cardColor, shadowColor),

              // Hỗ trợ
              _buildSupportSection(isDarkMode, cardColor, shadowColor),

              // Thanh điều hướng dưới cùng (đã có trong bottom navigation bar)
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thông tin người dùng với avatar
  Widget _buildUserInfoSection(bool isDarkMode, Color cardColor, Color textColor, Color cardBorderColor, Color shadowColor) {
    final userCardColor = isDarkMode ? const Color(0xFF2A2A2A) : cardColor;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: userCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          _isLoadingUserInfo
              ? CircleAvatar(
                  radius: 30,
                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 2,
                  ),
                )
              : CircleAvatar(
                  radius: 30,
                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  backgroundImage:
                      _userAvatar.isNotEmpty ? NetworkImage(_userAvatar) : null,
                  child: _userAvatar.isEmpty
                      ? Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : "U",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        )
                      : null,
                ),
          const SizedBox(width: 16),
          // Thông tin người dùng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoadingUserInfo
                    ? Text(
                        'Đang tải...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )
                    : Text(
                        _accountOverview?.accountName ?? (_userName.isNotEmpty ? _userName : 'Người dùng'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                const SizedBox(height: 4),
                _isLoadingUserInfo
                    ? Text(
                        '...',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                        ),
                      )
                    : Text(
                        _userEmail.isNotEmpty ? _userEmail : "Chưa có email",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
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
  Widget _buildOverviewSection(bool isDarkMode, Color textColor) {
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
          _isLoadingOverview || _isLoadingDayStreak
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      title: "Day Streaks",
                      value: _dayStreakController.currentStreak.toString(),
                      icon: Icons.local_fire_department,
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StreakScreen(
                                currentStreak:
                                    _dayStreakController.currentStreak),
                          ),
                        );
                      },
                    ),
                    _buildStatCard(
                      title: "Điểm",
                      value: _totalPoints.toString(),
                      icon: Icons.star,
                      color: accentColor,
                      onTap: () {
                        _navigateToRank();
                      },
                    ),
                    _buildStatCard(
                      title: "Khoá học",
                      value: _totalCourses.toString(),
                      icon: Icons.school,
                      color: blueColor,
                      onTap: () {
                        _navigateToMyCourses();
                      },
                    ),
                    _buildStatCard(
                      title: "Bài thi",
                      value: _totalDocument.toString(),
                      icon: Icons.description,
                      color: purpleColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyTestListScreen(),
                          ),
                        );
                      },
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
  Widget _buildLearningOutcomesSection(bool isDarkMode, Color cardColor, Color shadowColor) {
    final sectionCardColor = isDarkMode ? const Color(0xFF2A2A2A) : cardColor;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: sectionCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF3A3F55) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kết quả học tập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
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
  Widget _buildActivityHistorySection(bool isDarkMode, Color cardColor, Color shadowColor) {
    final sectionCardColor = isDarkMode ? const Color(0xFF2A2A2A) : cardColor;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: sectionCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF3A3F55) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Add navigation when needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lịch sử hoạt động',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.orange.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị lịch sử thanh toán
  Widget _buildPaymentHistorySection(bool isDarkMode, Color cardColor, Color shadowColor) {
    final sectionCardColor = isDarkMode ? const Color(0xFF2A2A2A) : cardColor;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: sectionCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF3A3F55) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (_accountOverview == null || _accountOverview!.accountId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tải lịch sử giao dịch. Thông tin tài khoản chưa sẵn sàng.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentHistoryScreen(
                accountId: _accountOverview?.accountId ?? 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 92, 233).withOpacity(isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color.fromARGB(255, 16, 92, 233),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lịch sử thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 16, 92, 233),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color.fromARGB(255, 41, 9, 252).withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hỗ trợ
  Widget _buildSupportSection(bool isDarkMode, Color cardColor, Color shadowColor) {
    final sectionCardColor = isDarkMode ? const Color(0xFF2A2A2A) : cardColor;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: sectionCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF3A3F55) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpAndSupportScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hỗ trợ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.green.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị ví của tôi
  Widget _buildWalletSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Chuyển đổi từ balanceWallet (double) sang định dạng hiển thị
    final balance = _balanceWallet;
    final formattedBalance = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(balance);

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
              builder: (context) => MyWalletScreen(
                initialBalance: _balanceWallet,
                walletId: _walletId,  
              ),
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
            gradient: LinearGradient(
              colors: isDarkMode 
                  ? [const Color(0xFF1E3A8A), const Color(0xFF0D2B76)] 
                  : [const Color(0xFF3498DB), const Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.4) 
                    : const Color(0xFF3498DB).withOpacity(0.3),
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
                    formattedBalance,
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: isDarkMode 
                                  ? const Color(0xFF1E3A8A) 
                                  : const Color(0xFF3498DB),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nạp tiền',
                              style: TextStyle(
                                color: isDarkMode 
                                    ? const Color(0xFF1E3A8A) 
                                    : const Color(0xFF3498DB),
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

  // Thêm phương thức để reload dữ liệu khi màn hình được focus lại
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kiểm tra xem có đang hiển thị màn hình này không
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _reloadDataIfNeeded();
    }
  }

  // Phương thức reload dữ liệu khi cần thiết
  Future<void> _reloadDataIfNeeded() async {
    try {
      // Lấy userId hiện tại từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString(SharedPrefs.KEY_USER_ID);

      // Kiểm tra cờ new_login
      final isNewLogin = prefs.getBool('new_login') ?? false;
      if (isNewLogin) {
        debugPrint('Phát hiện đăng nhập mới, reload dữ liệu');
        // Reset cờ
        await prefs.setBool('new_login', false);

        // Force reload
        await _loadUserInfo();
        await _loadAccountOverview();
        await _loadDayStreak();
        await _loadCartItemCount();
        return;
      }

      // So sánh với userId đã lưu trong model
      if (_accountOverview != null &&
          _accountOverview!.accountId.toString() != currentUserId) {
        debugPrint('Phát hiện thay đổi userId, reload dữ liệu');
        debugPrint(
            'Saved ID: ${_accountOverview!.accountId}, Current ID: $currentUserId');

        // Reload dữ liệu nếu userId thay đổi
        await _loadUserInfo();
        await _loadAccountOverview();
        await _loadDayStreak();
        await _loadCartItemCount();
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra cập nhật dữ liệu: $e');
    }
  }

  // Phương thức để xóa cache trong SharedPreferences
  Future<void> _clearSharedPrefsCache() async {
    try {
      debugPrint('Đang xóa cache...');

      // Lấy userId hiện tại để giữ lại
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString(SharedPrefs.KEY_USER_ID);
      final currentToken = prefs.getString('jwt');

      debugPrint('Current userId: $currentUserId');
      debugPrint(
          'Current token: ${currentToken != null ? "${currentToken.substring(0, 10)}..." : "null"}');

      // Xóa cache tạm thời (nếu cần)
      // Ở đây chúng ta không xóa userId và token để tránh mất đăng nhập

      // Force reload
      if (_accountOverview != null) {
        debugPrint('Force clearing account overview cache');
        setState(() {
          _accountOverview = null;
        });
      }

      // Tải lại số lượng giỏ hàng
      _loadCartItemCount();
    } catch (e) {
      debugPrint('Lỗi khi xóa cache: $e');
    }
  }
}
