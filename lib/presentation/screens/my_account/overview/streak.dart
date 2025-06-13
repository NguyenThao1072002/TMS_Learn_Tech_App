import 'package:flutter/material.dart';
// import 'package:tms_app/core/app_export.dart';
// import 'package:tms_app/presentation/widgets/app_bar/appbar_leading_image.dart';
// import 'package:tms_app/presentation/widgets/app_bar/appbar_title.dart';
// import 'package:tms_app/presentation/widgets/app_bar/custom_app_bar.dart';
// import 'package:tms_app/presentation/widgets/custom_elevated_button.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import 'dart:ui';
import 'package:tms_app/presentation/controller/day_streak_controller.dart';
import 'package:tms_app/data/models/streak/day_streak_model.dart';

class StreakScreen extends StatefulWidget {
  final int currentStreak;

  const StreakScreen({
    Key? key,
    required this.currentStreak,
  }) : super(key: key);

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  // Theme colors (temporary replacement for appTheme)
  late Color primaryColor;
  late Color accentColor;
  late Color blueColor;
  late Color bgColor;
  late Color gray300;
  late Color gray600;
  late Color purpleColor;
  late Color cardBgColor;
  late Color textColor;
  late Color textSecondaryColor;

  // Temporary TextStyles (replacement for CustomTextStyles)
  late TextStyle titleMedium;
  late TextStyle titleLarge;
  late TextStyle headlineLarge;
  late TextStyle bodyMedium;
  late TextStyle bodySmall;

  // Simulated streak history for the past 15 days (true = completed, false = missed)
  late List<bool> _streakHistory;
  late int _longestStreak;
  late double _completionRate;

  // Quản lý tháng hiển thị
  late DateTime _currentDisplayMonth;
  final Map<String, List<bool>> _monthlyActivityData = {};

  // Day streak controller
  late DayStreakController _dayStreakController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Khởi tạo với tháng hiện tại
    _currentDisplayMonth = DateTime.now();

    // Khởi tạo controller
    _dayStreakController = GetIt.instance<DayStreakController>();

    // Tải dữ liệu từ API
    _loadData();
  }

  void _initializeThemeColors(bool isDarkMode) {
    primaryColor = Colors.orange;
    accentColor = Colors.deepOrange;
    blueColor = Colors.blue;
    bgColor = isDarkMode ? Color(0xFF121212) : Colors.white;
    cardBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    gray300 = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    gray600 = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    purpleColor = Colors.purple;
    textColor = isDarkMode ? Colors.white : Colors.black87;
    textSecondaryColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor);
    titleLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor);
    headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: textColor);
    bodyMedium = TextStyle(fontSize: 14, color: textColor);
    bodySmall = TextStyle(fontSize: 12, color: textSecondaryColor);
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Tải dữ liệu từ API
      await _dayStreakController.loadDayStreak();

      if (_dayStreakController.error != null) {
        setState(() {
          _error = _dayStreakController.error;
          _isLoading = false;
        });
        return;
      }

      // Khởi tạo streak history từ dữ liệu API
      _initializeStreakHistory();
      _calculateStats();
      _generateMonthlyData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Đã xảy ra lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _initializeStreakHistory() {
    // Lấy 15 ngày gần nhất để hiển thị streak history
    final now = DateTime.now();
    _streakHistory = List.generate(15, (index) {
      final date = now.subtract(Duration(days: 14 - index));
      return _dayStreakController.isActiveDate(date);
    });
  }

  void _generateMonthlyData() {
    // Tạo dữ liệu cho các tháng
    final now = DateTime.now();

    // Tạo dữ liệu cho 6 tháng trước đến 1 tháng sau
    for (int i = -6; i <= 1; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final monthKey = '${month.year}-${month.month}';

      if (!_monthlyActivityData.containsKey(monthKey)) {
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

        // Tạo dữ liệu cho tháng này
        final List<bool> monthData = List.generate(daysInMonth, (index) {
          final day = index + 1;
          final date = DateTime(month.year, month.month, day);

          // Kiểm tra xem ngày này có trong danh sách activeDates không
          if (date.isAfter(now)) {
            // Ngày trong tương lai
            return false;
          } else {
            // Sử dụng dữ liệu thực từ API
            return _dayStreakController.isActiveDate(date);
          }
        });

        _monthlyActivityData[monthKey] = monthData;
      }
    }
  }

  // Chuyển đến tháng trước
  void _previousMonth() {
    setState(() {
      _currentDisplayMonth = DateTime(
          _currentDisplayMonth.year, _currentDisplayMonth.month - 1, 1);
    });
  }

  // Chuyển đến tháng sau
  void _nextMonth() {
    // Không cho phép chuyển đến tháng trong tương lai quá xa
    final now = DateTime.now();
    final nextMonth =
        DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1, 1);

    if (nextMonth.year < now.year ||
        (nextMonth.year == now.year && nextMonth.month <= now.month + 1)) {
      setState(() {
        _currentDisplayMonth = nextMonth;
      });
    }
  }

  void _calculateStats() {
    // Lấy longest streak từ API
    _longestStreak = _dayStreakController.maxStreak;

    // Tính tỷ lệ hoàn thành trong 30 ngày gần nhất
    _completionRate = _dayStreakController.getCompletionRate();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _initializeThemeColors(isDarkMode);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDarkMode),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không thể tải dữ liệu',
                        style: titleLarge.copyWith(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: bodyMedium.copyWith(color: gray600),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakOverview(),
                      const SizedBox(height: 24),
                      _buildStreakStats(isDarkMode),
                      const SizedBox(height: 24),
                      _buildActivityCalendar(isDarkMode),
                      const SizedBox(height: 24),
                      _buildStreakTips(isDarkMode),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Học liên tục",
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18),
      ),
      actions: [
        // Nút refresh để tải lại dữ liệu
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.blue),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildStreakOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chuỗi ngày học",
                    style: titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${_dayStreakController.currentStreak} ngày",
                    style: headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakAction(
                icon: Icons.notifications,
                label: "Nhắc nhở",
                onTap: () {
                  // Handle reminder setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Đã bật nhắc nhở học tập hàng ngày"),
                      backgroundColor: accentColor,
                    ),
                  );
                },
              ),
              _buildStreakAction(
                icon: Icons.share,
                label: "Chia sẻ",
                onTap: () {
                  // Handle sharing
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Đã chia sẻ thành tích"),
                      backgroundColor: accentColor,
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

  Widget _buildStreakAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStats(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thống kê",
            style: titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  iconColor: accentColor,
                  value: _longestStreak.toString(),
                  label: "Chuỗi dài nhất",
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today,
                  iconColor: blueColor,
                  value: "${_completionRate.toStringAsFixed(0)}%",
                  label: "Tỷ lệ hoàn thành",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: bodySmall.copyWith(
            color: gray600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityCalendar(bool isDarkMode) {
    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Lấy thông tin tháng đang hiển thị
    final daysInMonth =
        DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1, 0)
            .day;
    final firstDayOfMonth =
        DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    // Lấy danh sách hoạt động của tháng được chọn
    final monthKey =
        '${_currentDisplayMonth.year}-${_currentDisplayMonth.month}';
    final monthData = _monthlyActivityData[monthKey] ??
        List.generate(daysInMonth, (index) => false);

    // Kiểm tra xem tháng hiển thị có phải là tháng hiện tại không
    final isCurrentMonth = _currentDisplayMonth.year == now.year &&
        _currentDisplayMonth.month == now.month;

    // Danh sách tháng
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lịch sử hoạt động",
                style: titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bộ chọn tháng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                color: primaryColor,
              ),
              Text(
                "${months[_currentDisplayMonth.month - 1]} ${_currentDisplayMonth.year}",
                style: titleMedium.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: isCurrentMonth ? null : _nextMonth,
                color: primaryColor,
                disabledColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Hiển thị tên các ngày trong tuần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["M", "T", "W", "T", "F", "S", "S"]
                .map((day) => SizedBox(
                      width: 30,
                      child: Text(
                        day,
                        style: bodySmall.copyWith(
                          color: gray600,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Lịch hiển thị theo tháng
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 rows of 7 days
            itemBuilder: (context, index) {
              // Tính toán ngày hiển thị
              final dayOffset = index - (firstWeekday - 1);
              final day = dayOffset + 1;

              // Kiểm tra ngày hợp lệ
              if (dayOffset < 0 || day > daysInMonth) {
                return const SizedBox.shrink();
              }

              // Tạo đối tượng DateTime cho ngày này
              final date = DateTime(
                  _currentDisplayMonth.year, _currentDisplayMonth.month, day);

              // Kiểm tra ngày hiện tại
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              // Kiểm tra ngày có trong tháng hiện tại và đã qua
              final isActive = date.isBefore(now.add(const Duration(days: 1)));

              // Kiểm tra ngày có hoạt động học tập (sử dụng dữ liệu từ API)
              final isCompleted = _dayStreakController.isActiveDate(date);

              return _buildCalendarDay(
                day.toString(),
                isToday: isToday,
                isActive: isActive,
                isCompleted: isCompleted,
                isDarkMode: isDarkMode,
              );
            },
          ),

          const SizedBox(height: 16),

          // Chú thích
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  icon: Icons.local_fire_department,
                  color: primaryColor,
                  label: "Hoàn thành"),
              const SizedBox(width: 24),
              _buildLegendItem(
                  icon: Icons.close, color: gray300, label: "Bỏ lỡ"),
            ],
          ),

          // Hiển thị thông tin streak khi xem tháng hiện tại
          if (isCurrentMonth && _dayStreakController.currentStreak >= 7)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_dayStreakController.currentStreak} ngày liên tục!",
                          style: titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Bạn đang xây dựng thói quen học tập tốt. Hãy tiếp tục duy trì!",
                          style: bodySmall.copyWith(color: gray600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    String day, {
    bool isToday = false,
    bool isActive = false,
    bool isCompleted = false,
    required bool isDarkMode,
  }) {
    // Màu mặc định
    Color bgColor = Colors.transparent;
    Color textColor = isActive 
        ? (isDarkMode ? Colors.white : Colors.black) 
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);
    BoxDecoration decoration;
    FontWeight fontWeight = FontWeight.normal;

    // Hoàn thành
    if (isCompleted) {
      // Ngày đã hoàn thành
      decoration = BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      );
      textColor = Colors.white;
      fontWeight = FontWeight.w500;
    }
    // Hôm nay nhưng chưa hoàn thành
    else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: blueColor, width: 2),
        shape: BoxShape.circle,
      );
      textColor = blueColor;
      fontWeight = FontWeight.bold;
    }
    // Ngày thường
    else {
      decoration = const BoxDecoration(
        color: Colors.transparent,
      );
    }

    return Container(
      decoration: decoration,
      child: Center(
        child: Text(
          day,
          style: bodyMedium.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: bodySmall.copyWith(
            color: gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakTips(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mẹo học liên tục",
            style: titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            icon: Icons.access_time,
            tip: "Học cùng một thời điểm mỗi ngày để tạo thói quen.",
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.notifications_active,
            tip: "Bật thông báo nhắc nhở để không bỏ lỡ ngày học.",
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.bar_chart,
            tip: "Đặt mục tiêu nhỏ và tăng dần độ khó để duy trì động lực.",
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String tip,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tip,
            style: bodyMedium,
          ),
        ),
      ],
    );
  }
}
