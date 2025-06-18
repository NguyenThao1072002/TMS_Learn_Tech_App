import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/models/ranking/ranking.dart';
import 'package:tms_app/data/models/reward/rank_reward.dart';
import 'package:tms_app/presentation/controller/ranking_controller.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({Key? key}) : super(key: key);

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Ranking> _weeklyRankings;
  late List<Ranking> _monthlyRankings;
  late List<Ranking> _allTimeRankings;
  late List<RankReward> _rewards;
  late List<Ranking> _rankings;
  final List<String> _tabs = ["Tuần này", "Tháng này", "Tổng"];
//
  // Gradient colors for various UI elements
  late List<Color> _gradientColors;

  // Medal colors
  final Color _goldColor = const Color(0xFFFFD700);
  final Color _silverColor = const Color(0xFFC0C0C0);
  final Color _bronzeColor = const Color(0xFFCD7F32);

  // Màu sắc nổi bật và đặc biệt cho UI
  late Color _accentColor;
  late Color _secondaryAccentColor;
  late Color _backgroundStartColor;
  late Color _backgroundEndColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _textSecondaryColor;
  late Color _dividerColor;
  late Color _shadowColor;

  // Thông tin điểm người dùng
  int _userPoints = 0;
  final int _pointsGainedToday = 25;
  int _currentUserRank = 0; // Hạng hiện tại của người dùng
  bool _showRewardsPanel = false;
  bool _hasShownCongratulations = false; // Kiểm tra đã hiển thị chúc mừng chưa

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _weeklyRankings = [];
    _monthlyRankings = [];
    _allTimeRankings = [];
    _loadData();

    // Initialize colors with default values (light mode)
    _initializeColors(false);

    // Generate mock data
    // _generateMockData();
    _initializeRewards();
    // Thêm hiệu ứng animation khi chuyển tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Hiển thị thông báo chúc mừng sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCongratulationsDialog();
    });
  }

  void _initializeColors(bool isDarkMode) {
    // Base gradient colors
    _gradientColors = [
      const Color(0xFF6448FE),
      const Color(0xFF5FC6FF),
    ];

    // Theme-specific colors
    _accentColor = const Color(0xFF5FC6FF);
    _secondaryAccentColor = const Color(0xFFFF5E84);

    // Background colors
    if (isDarkMode) {
      _backgroundStartColor = const Color(0xFF121212);
      _backgroundEndColor = const Color(0xFF1E1E1E);
      _cardColor = const Color(0xFF2A2D3E);
      _textColor = Colors.white;
      _textSecondaryColor = Colors.white70;
      _dividerColor = Colors.grey.shade800;
      _shadowColor = Colors.black.withOpacity(0.3);
    } else {
      _backgroundStartColor = const Color(0xFFF6F9FC);
      _backgroundEndColor = const Color(0xFFEDF1F7);
      _cardColor = Colors.white;
      _textColor = Colors.black87;
      _textSecondaryColor = Colors.black54;
      _dividerColor = Colors.grey.shade300;
      _shadowColor = Colors.grey.withOpacity(0.1);
    }
  }

  void _generateMockData() {
    // Mock user names
    final List<String> names = [
      "Thu Thảo",
      "Minh Nhật",
      "Quốc Anh",
      "Hoàng Yến",
      "Thanh Hà",
      "Đức Minh",
      "Bảo Nam",
      "Mỹ Linh",
      "Quang Dũng",
      "Ngọc Ánh",
      "Phương Linh",
      "Tuấn Anh",
      "Thanh Tùng",
      "Bích Ngọc",
      "Minh Tú",
      "Hồng Nhung",
      "Văn Khoa",
      "Thùy Dương",
      "Quang Minh",
      "Khánh Linh",
      "Hải Đăng",
      "Thảo Vy",
      "Nam Cường",
      "Huyền Trang",
      "Thành Đạt"
    ];

    // Mock avatars - normally these would be urls, but for this example we'll use color codes
    // to render colored circles
    final List<String> avatars = [
      "assets/images/avatar1.jpg",
      "assets/images/avatar2.jpg",
      "assets/images/avatar3.jpg",
      "assets/images/avatar4.jpg",
      "assets/images/avatar5.jpg",
      "assets/images/avatar6.jpg",
      "assets/images/avatar7.jpg",
      "assets/images/avatar8.jpg",
      "assets/images/avatar9.jpg",
      "assets/images/avatar10.jpg",
      "assets/images/avatar11.jpg",
      "assets/images/avatar12.jpg",
      "assets/images/avatar13.jpg",
      "assets/images/avatar14.jpg",
      "assets/images/avatar15.jpg",
      "assets/images/avatar16.jpg",
      "assets/images/avatar17.jpg",
      "assets/images/avatar18.jpg",
      "assets/images/avatar19.jpg",
      "assets/images/avatar20.jpg",
      "assets/images/avatar21.jpg",
      "assets/images/avatar22.jpg",
      "assets/images/avatar23.jpg",
      "assets/images/avatar24.jpg",
      "assets/images/avatar25.jpg",
    ];

    // Generate weekly rankings
    _weeklyRankings = _generateRankings(names, avatars);

    // Generate monthly rankings with different point values
    _monthlyRankings = _generateRankings(names, avatars, multiplier: 4);

    // Generate all-time rankings with the highest values
    _allTimeRankings = _generateRankings(names, avatars, multiplier: 12);
  }

  void _initializeRewards() {
    _rewards = [
      RankReward(
        name: 'Khóa học miễn phí',
        description: 'Nhận 1 khóa học miễn phí trị giá lên đến 500.000đ',
        icon: Icons.school,
        color: Colors.blue,
        requiredRank: 1,
        isVoucher: true,
        voucherCode: 'TOP1REWARD',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Giảm 50% khóa học',
        description: 'Giảm 50% cho 1 khóa học bất kỳ',
        icon: Icons.discount,
        color: Colors.purple,
        requiredRank: 2,
        isVoucher: true,
        voucherCode: 'TOP2REWARD',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Giảm 30% khóa học',
        description: 'Giảm 30% cho 1 khóa học bất kỳ',
        icon: Icons.local_offer,
        color: Colors.orange,
        requiredRank: 3,
        isVoucher: true,
        voucherCode: 'TOP3REWARD',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Buổi hướng dẫn 1-1',
        description: 'Buổi hướng dẫn trực tiếp với giảng viên (45 phút)',
        icon: Icons.person,
        color: Colors.teal,
        requiredRank: 4,
      ),
      RankReward(
        name: 'Mở khóa tài liệu đặc biệt',
        description: 'Truy cập bộ tài liệu cao cấp và đề thi mẫu',
        icon: Icons.menu_book,
        color: Colors.indigo,
        requiredRank: 5,
      ),
      RankReward(
        name: 'Giảm 20% khóa học',
        description: 'Giảm 20% cho 1 khóa học bất kỳ',
        icon: Icons.card_giftcard,
        color: Colors.green,
        requiredRank: 7,
        isVoucher: true,
        voucherCode: 'TOP7REWARD',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Huy hiệu Top 10',
        description: 'Hiển thị huy hiệu đặc biệt trên trang cá nhân',
        icon: Icons.workspace_premium,
        color: Colors.amber,
        requiredRank: 10,
      ),
      RankReward(
        name: 'Quyền ưu tiên đăng ký',
        description: 'Đăng ký sớm các khóa học mới',
        icon: Icons.access_time_filled,
        color: Colors.deepOrange,
        requiredRank: 15,
      ),
      RankReward(
        name: 'Giảm 15% khóa học',
        description: 'Giảm 15% cho 1 khóa học bất kỳ',
        icon: Icons.local_mall,
        color: Colors.green,
        requiredRank: 20,
        isVoucher: true,
        voucherCode: 'TOP20REWARD',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Tư vấn khóa học riêng',
        description: 'Buổi tư vấn lộ trình học phù hợp với nhu cầu riêng',
        icon: Icons.timeline,
        color: Colors.deepPurple,
        requiredRank: 25,
      ),
      RankReward(
        name: 'Giảm 10% học phí',
        description: 'Giảm 10% học phí tất cả khóa học trong 1 tháng',
        icon: Icons.discount_outlined,
        color: Colors.red,
        requiredRank: 30,
        isVoucher: true,
        voucherCode: 'MONTH10POFF',
        expiryDate: '31/12/2024',
      ),
      RankReward(
        name: 'Quyền truy cập beta',
        description: 'Truy cập những tính năng và khóa học đang phát triển',
        icon: Icons.new_releases,
        color: Colors.blueGrey,
        requiredRank: 35,
      ),
    ];
  }

  List<Ranking> _generateRankings(List<String> names, List<String> avatars,
      {int multiplier = 1}) {
    // Make a copy of the names and shuffle them to create random rankings
    final shuffledIndices = List<int>.generate(names.length, (i) => i)
      ..shuffle(
          math.Random(DateTime.now().millisecondsSinceEpoch + multiplier));

    // Create a list of rankings
    final rankings = <Ranking>[];

    for (int i = 0; i < names.length; i++) {
      final index = shuffledIndices[i];
      final isCurrentUser =
          i == _currentUserRank - 1; // Đặt người dùng hiện tại ở hạng 8

      // Create ranking entry with calculated points
      // Top ranks have higher points
      final points = (1000 - (i * 50)) * multiplier;

      rankings.add(
        Ranking(
          id: 0,
          accountId: 0,
          accountName: names[index],
          periodType: 'week',
          totalPoints: points,
          ranking: i + 1,
          status: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          isCurrentUser: isCurrentUser,
          level: 1, // Assuming a default level
          completedCourses: 0, // Assuming no completed courses
        ),
      );
    }

    return rankings;
  }

  Future<void> _loadData() async {
    final rankingController = GetIt.instance<RankingController>();
    await rankingController.loadRankings('week');
    setState(() {
      _currentUserRank = rankingController.currentUserRanking;
      _userPoints = rankingController.currentUserPoints;
      _rankings = rankingController.rankings ?? [];
      _weeklyRankings = _rankings;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Initialize colors based on theme
    _initializeColors(isDarkMode);
    _rankings = GetIt.instance<RankingController>().rankings ?? [];

    if (_rankings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundStartColor,
                  _backgroundEndColor,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildAppBar(isDarkMode),
                        const SizedBox(height: 16),
                        _buildPointsCard(isDarkMode),
                        const SizedBox(height: 20),
                        _buildRewardsButton(isDarkMode),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      child: _buildTabBar(isDarkMode),
                    ),
                    pinned: true,
                    floating: true,
                  ),
                ];
              },
              body: _buildRankingsList(isDarkMode),
            ),
          ),

          // Panel phần thưởng (hiển thị khi bấm nút phần thưởng)
          if (_showRewardsPanel) _buildRewardsPanel(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _gradientColors[0].withOpacity(0.05),
            _gradientColors[1].withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút back với hiệu ứng ripple
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: _textColor,
                ),
              ),
            ),
          ),
          // Tiêu đề với hiệu ứng gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_gradientColors[0], _gradientColors[1]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Bảng xếp hạng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Màu này sẽ được thay thế bởi gradient
              ),
            ),
          ),
          // Nút thông tin với hiệu ứng ripple
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                // Hiển thị thông tin về cách tính điểm
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
                            isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF8F9FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _shadowColor,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header với gradient
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.stars,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cách tính điểm',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Cải thiện điểm số để đạt thứ hạng cao!',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Giải thích về học và kiểm tra
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: _shadowColor,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hệ thống học tập',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Cách tính điểm chi tiết với các icon
                                  _buildPointItem(
                                    icon: Icons.play_circle_filled,
                                    color: Colors.blue,
                                    title: 'Hoàn thành video bài học',
                                    points: '+5 điểm',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPointItem(
                                    icon: Icons.quiz,
                                    color: Colors.orange,
                                    title: 'Hoàn thành bài kiểm tra',
                                    points: '+10 điểm',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPointItem(
                                    icon: Icons.assessment,
                                    color: Colors.purple,
                                    title: 'Hoàn thành bài kiểm tra chương',
                                    points: '+30 điểm',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPointItem(
                                    icon: Icons.grading,
                                    color: Colors.green,
                                    title: 'Đạt điểm tuyệt đối (100%)',
                                    points: '+5 điểm bổ sung',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPointItem(
                                    icon: Icons.local_fire_department,
                                    color: Colors.red,
                                    title: 'Duy trì học tập 7 ngày liên tục',
                                    points: '+25 điểm',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPointItem(
                                    icon: Icons.workspace_premium,
                                    color: Colors.amber,
                                    title: 'Hoàn thành toàn bộ khóa học',
                                    points: '+100 điểm',
                                    isDarkMode: isDarkMode,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Ghi chú và nút đóng
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.amber.withOpacity(0.1)
                                    : const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.amber.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Điểm xếp hạng được cập nhật hàng giờ. Duy trì học tập đều đặn để tăng điểm nhanh nhất!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Nút đóng
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gradientColors[0],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Đã hiểu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  color: _textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thẻ chính với hiệu ứng gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Biểu tượng cúp với hiệu ứng phát sáng
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Thông tin điểm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Điểm xếp hạng của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_userPoints}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'điểm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Badge hiển thị điểm tăng trong ngày
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: _accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${_pointsGainedToday}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsButton(bool isDarkMode) {
    // Tìm reward phù hợp với rank hiện tại của người dùng
    final availableRewards = _rewards
        .where((reward) => reward.requiredRank >= _currentUserRank)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showRewardsPanel = !_showRewardsPanel;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF8A65),
                  const Color(0xFFFF5722),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phần thưởng & Đặc quyền',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        availableRewards.isNotEmpty
                            ? 'Bạn đang có ${availableRewards.length} phần thưởng khả dụng!'
                            : 'Hãy cải thiện thứ hạng để nhận phần thưởng!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: _gradientColors,
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildRankingsList(bool isDarkMode) {
    return Expanded(
      child: Scrollbar(
        thickness: 5,
        radius: const Radius.circular(10),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRankingsTab(_weeklyRankings, isDarkMode),
            _buildRankingsTab(_monthlyRankings, isDarkMode),
            _buildRankingsTab(_allTimeRankings, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsTab(List<Ranking> rankings, bool isDarkMode) {
    // Find the current user's rank for highlighting
    final currentUserIndex = rankings.indexWhere((user) => user.isCurrentUser);

    return CustomScrollView(
      slivers: [
        // Top spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),

        // Podium card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: rankings.length >= 3
                ? _buildPodium(rankings.take(3).toList(), isDarkMode)
                : const SizedBox(height: 20),
          ),
        ),

        // Spacing between podium and list
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),

        // Title for rankings list
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Bảng xếp hạng chi tiết',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ),
        ),

        // List of rankings
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skip the top 3 as they are shown in the podium
                if (index < 3) return const SizedBox.shrink();

                if (index >= rankings.length) return null;

                final user = rankings[index];

                return _buildRankItem(user, isDarkMode);
              },
              childCount: rankings.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<Ranking> topThree, bool isDarkMode) {
    // Sort users by rank to ensure proper podium display
    topThree.sort((a, b) => a.ranking.compareTo(b.ranking));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              _buildPodiumItem(
                topThree[1],
                height: 110,
                medal: 'assets/silver_medal.png',
                medalColor: const Color(0xFFC0C0C0),
                podiumColor: const Color(0xFFE0E0E0),
                rank: 2,
                isDarkMode: isDarkMode,
              ),

              // 1st place
              _buildPodiumItem(
                topThree[0],
                height: 140,
                medal: 'assets/gold_medal.png',
                medalColor: const Color(0xFFFFD700),
                podiumColor: const Color(0xFFFFC107),
                rank: 1,
                isDarkMode: isDarkMode,
              ),

              // 3rd place
              _buildPodiumItem(
                topThree[2],
                height: 90,
                medal: 'assets/bronze_medal.png',
                medalColor: const Color(0xFFCD7F32),
                podiumColor: const Color(0xFFBCAAA4),
                rank: 3,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),

        // Trophy decoration
        Positioned(
          top: -15,
          right: 20,
          child: Icon(
            Icons.emoji_events,
            size: 40,
            color: Colors.amber.shade700,
          ),
        ),

        // Crown decoration for 1st place
        Positioned(
          top: -10,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.workspace_premium,
              size: 30,
              color: Colors.amber.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(
    Ranking user, {
    required double height,
    required String medal,
    required Color medalColor,
    required Color podiumColor,
    required int rank,
    required bool isDarkMode,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username and points
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: medalColor.withOpacity(0.5), width: 1),
          ),
          child: Column(
            children: [
              Text(
                user.accountName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${NumberFormat('#,###').format(user.totalPoints)}',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // User avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: medalColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage:
                    user.avatar != null ? NetworkImage(user.avatar!) : null,
                child: user.avatar == null
                    ? const Icon(Icons.person, size: 28, color: Colors.grey)
                    : null,
              ),
            ),

            // Medal badge
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: medalColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                podiumColor.withOpacity(0.7),
                podiumColor,
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                'Lv.${user.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(Ranking user, bool isDarkMode) {
    return Card(
      elevation: user.isCurrentUser ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: user.isCurrentUser
            ? BorderSide(color: _accentColor, width: 1.5)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Rank number with background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getRankColors(user.ranking),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(user.ranking <= 3 ? 8 : 18),
              ),
              alignment: Alignment.center,
              child: _getRankIcon(user.ranking),
            ),
            const SizedBox(width: 12),

            // User avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(user.accountName[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),

            // User info (name, level, completed courses)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.accountName,
                          style: TextStyle(
                            fontWeight: user.isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                            color: user.isCurrentUser
                                ? _accentColor
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor(user.level).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 14,
                              color: _getLevelColor(user.level),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Level ${user.level}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getLevelColor(user.level),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${user.completedCourses} khóa học hoàn thành',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Bạn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Points display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.totalPoints}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: user.ranking <= 3
                        ? _getRankColors(user.ranking)[1]
                        : Colors.black87,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get level color
  Color _getLevelColor(int level) {
    if (level >= 20) {
      return const Color(0xFF6200EA); // Deep Purple for high levels
    } else if (level >= 15) {
      return const Color(0xFF2962FF); // Blue for advanced levels
    } else if (level >= 10) {
      return const Color(0xFF00B0FF); // Light Blue for intermediate levels
    } else if (level >= 5) {
      return const Color(0xFF00BFA5); // Teal for beginner levels
    } else {
      return const Color(0xFF66BB6A); // Green for novice levels
    }
  }

  // Helper method to get rank icon
  Widget _getRankIcon(int rank) {
    if (rank == 1) {
      return const Icon(Icons.looks_one, color: Colors.white, size: 18);
    } else if (rank == 2) {
      return const Icon(Icons.looks_two, color: Colors.white, size: 18);
    } else if (rank == 3) {
      return const Icon(Icons.looks_3, color: Colors.white, size: 18);
    } else {
      return Text(
        '$rank',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
  }

  // Helper method to get rank colors
  List<Color> _getRankColors(int rank) {
    if (rank == 1) {
      return [const Color(0xFFFFD700), const Color(0xFFFFA000)]; // Gold
    } else if (rank == 2) {
      return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Silver
    } else if (rank == 3) {
      return [const Color(0xFFCD7F32), const Color(0xFFAB5F15)]; // Bronze
    } else if (rank <= 10) {
      return [
        const Color(0xFF64B5F6),
        const Color(0xFF1976D2)
      ]; // Blue for top 10
    } else {
      return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  // Phương thức tạo mục cách tính điểm
  Widget _buildPointItem({
    required IconData icon,
    required Color color,
    required String title,
    required String points,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: _textColor,
            ),
          ),
        ),
        Text(
          points,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Hiển thị popup chúc mừng nếu người dùng đủ điều kiện
  void _showCongratulationsDialog() {
    if (!_hasShownCongratulations && _currentUserRank <= 10) {
      _hasShownCongratulations = true;

      // Tìm phần thưởng phù hợp với rank hiện tại
      final unlockedRewards = _rewards
          .where((reward) => reward.requiredRank >= _currentUserRank)
          .take(1)
          .toList();

      if (unlockedRewards.isEmpty) return;

      final reward = unlockedRewards.first;

      // Hiển thị dialog chúc mừng
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          barrierDismissible: false, // Người dùng phải nhấn nút để đóng
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF8F9FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hiệu ứng pháo hoa
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                reward.color.withOpacity(0.5),
                                reward.color.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          reward.icon,
                          size: 60,
                          color: reward.color,
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildConfetti(Colors.blue, const Offset(-1, -1),
                                  const Duration(seconds: 1)),
                              _buildConfetti(Colors.red, const Offset(0, -1),
                                  const Duration(milliseconds: 800)),
                              _buildConfetti(Colors.yellow, const Offset(1, -1),
                                  const Duration(milliseconds: 1200)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tiêu đề chúc mừng
                    Text(
                      'Chúc mừng!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: reward.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nội dung chúc mừng
                    Text(
                      'Bạn đã đạt hạng $_currentUserRank trên bảng xếp hạng!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: reward.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Phần thưởng:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                reward.icon,
                                color: reward.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                reward.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: reward.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tiếp tục duy trì thứ hạng để mở khóa nhiều phần thưởng giá trị hơn!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Nút nhận thưởng
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Mở tab phần thưởng
                        setState(() {
                          _showRewardsPanel = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: reward.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Xem phần thưởng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
  }

  // Tạo hiệu ứng confetti cho popup chúc mừng
  Widget _buildConfetti(Color color, Offset direction, Duration delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            direction.dx * 40 * value,
            direction.dy * 50 * value,
          ),
          child: Opacity(
            opacity: 1 - value,
            child: Icon(
              Icons.star,
              color: color,
              size: 20 * (1 - value * 0.5),
            ),
          ),
        );
      },
    );
  }

  // Hiển thị panel phần thưởng xếp hạng
  Widget _buildRewardsPanel(bool isDarkMode) {
    // Phần thưởng cho các hạng khác nhau
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showRewardsPanel = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Phần thưởng & Đặc quyền',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Đạt hạng cao hơn để mở khóa phần thưởng',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _showRewardsPanel = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Scrollbar(
                      thickness: 5,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20, top: 8),
                        shrinkWrap: true,
                        itemCount: _rewards.length,
                        itemBuilder: (context, index) {
                          final reward = _rewards[index];
                          final bool isUnlocked =
                              _currentUserRank <= reward.requiredRank;
                          final bool isCurrentUser =
                              reward.requiredRank == _currentUserRank;

                          return Card(
                            elevation: isUnlocked ? 2 : 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            color: isUnlocked
                                ? Colors.white
                                : Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isUnlocked
                                  ? BorderSide(
                                      color: reward.color.withOpacity(0.5),
                                      width: 1)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: reward.color.withOpacity(
                                              isUnlocked ? 0.2 : 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          reward.icon,
                                          color: isUnlocked
                                              ? reward.color
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    reward.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: isUnlocked
                                                          ? Colors.black87
                                                          : Colors.grey,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isUnlocked
                                                        ? reward.color
                                                            .withOpacity(0.1)
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Top ${reward.requiredRank}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isUnlocked
                                                              ? reward.color
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                      if (isCurrentUser)
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 4),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 1),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _accentColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: const Text(
                                                            'Bạn',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              reward.description,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isUnlocked
                                                    ? Colors.black54
                                                    : Colors.grey,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isUnlocked && reward.isVoucher) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  reward.voucherCode!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.copy,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Hiển thị mã voucher hoặc đặc quyền
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Đã sao chép mã: ${reward.voucherCode}'),
                                                action: SnackBarAction(
                                                  label: 'OK',
                                                  onPressed: () {},
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: reward.color,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                          ),
                                          child: const Text('Dùng',
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    if (reward.expiryDate != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'HSD: ${reward.expiryDate}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                  if (!isUnlocked) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lock_outline,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Cần đạt Top ${reward.requiredRank} để mở khóa',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Footer note
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Phần thưởng sẽ được cập nhật sau mỗi chu kỳ xếp hạng. '
                            'Một số phần thưởng có thể có hạn sử dụng.',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Delegate để tạo header cố định khi cuộn
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF6F9FC),
      child: child,
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
