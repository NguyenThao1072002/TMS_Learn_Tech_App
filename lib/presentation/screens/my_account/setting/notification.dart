import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Trạng thái các loại thông báo
  bool _dailyReminder = true;
  bool _streakReminder = true;
  bool _commentNotification = true;
  bool _promotionNotification = false;
  bool _courseUpdateNotification = true;
  bool _testReminderNotification = true;
  bool _achievementNotification = true;

  // Controllers cho thời gian nhắc nhở
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái dark mode từ Theme hiện tại
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colors for dark and light mode
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final dividerColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final iconColor = isDarkMode ? Colors.white : null;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text(
          'Cài đặt thông báo',
          style: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header thông tin
            _buildInfoHeader(isDarkMode),
            const SizedBox(height: 24),

            // Nhắc nhở hàng ngày
            _buildSectionTitle('Nhắc nhở học tập', textColor),
            _buildNotificationItem(
              title: 'Nhắc nhở học tập hàng ngày',
              subtitle:
                  'Nhận thông báo nhắc nhở học tập vào ${_formatTimeOfDay(_reminderTime)}',
              value: _dailyReminder,
              onChanged: (value) {
                setState(() {
                  _dailyReminder = value;
                });
              },
              hasTimeSelector: true,
              onTimeTap: () {
                _selectTime(context);
              },
              isDarkMode: isDarkMode,
            ),
            _buildNotificationItem(
              title: 'Nhắc nhở giữ streak',
              subtitle:
                  'Nhận thông báo khi gần đến thời hạn để duy trì streak học tập',
              value: _streakReminder,
              onChanged: (value) {
                setState(() {
                  _streakReminder = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildNotificationItem(
              title: 'Nhắc nhở kiểm tra và bài tập',
              subtitle: 'Thông báo về bài kiểm tra và thời hạn nộp bài tập',
              value: _testReminderNotification,
              onChanged: (value) {
                setState(() {
                  _testReminderNotification = value;
                });
              },
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 8),
            _buildSectionTitle('Tương tác và cập nhật', textColor),
            _buildNotificationItem(
              title: 'Bình luận và phản hồi',
              subtitle:
                  'Thông báo khi có người phản hồi bình luận hoặc bài đăng của bạn',
              value: _commentNotification,
              onChanged: (value) {
                setState(() {
                  _commentNotification = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildNotificationItem(
              title: 'Cập nhật khóa học',
              subtitle:
                  'Thông báo khi có nội dung mới hoặc thay đổi trong khóa học của bạn',
              value: _courseUpdateNotification,
              onChanged: (value) {
                setState(() {
                  _courseUpdateNotification = value;
                });
              },
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 8),
            _buildSectionTitle('Thành tích và ưu đãi', textColor),
            _buildNotificationItem(
              title: 'Thông báo thành tích',
              subtitle:
                  'Thông báo khi bạn đạt được thành tích hoặc mốc học tập mới',
              value: _achievementNotification,
              onChanged: (value) {
                setState(() {
                  _achievementNotification = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildNotificationItem(
              title: 'Khuyến mãi và ưu đãi',
              subtitle: 'Thông báo về các ưu đãi, giảm giá và sự kiện đặc biệt',
              value: _promotionNotification,
              onChanged: (value) {
                setState(() {
                  _promotionNotification = value;
                });
              },
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 32),
            // Nút đặt lại mặc định
            Center(
              child: TextButton.icon(
                onPressed: _showResetConfirmDialog,
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  'Đặt lại mặc định',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tiêu đề khu vực
  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // Widget hiển thị thông tin header
  Widget _buildInfoHeader(bool isDarkMode) {
    final headerBgColor = isDarkMode 
        ? Colors.blue.withOpacity(0.15) 
        : Colors.blue.withOpacity(0.05);
    final headerBorderColor = isDarkMode 
        ? Colors.blue.withOpacity(0.3) 
        : Colors.blue.withOpacity(0.1);
    final iconBgColor = isDarkMode 
        ? Colors.blue.withOpacity(0.2) 
        : Colors.blue.withOpacity(0.1);
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final descriptionColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: headerBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.notifications_active, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cài đặt thông báo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tùy chỉnh cách bạn nhận thông báo từ ứng dụng. Bạn có thể bật/tắt từng loại thông báo khác nhau.',
                  style: TextStyle(
                    fontSize: 14,
                    color: descriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị mục thông báo
  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasTimeSelector = false,
    VoidCallback? onTimeTap,
    required bool isDarkMode,
  }) {
    final cardBgColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final cardBorderColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey.shade200;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final cardShadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.05);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          if (hasTimeSelector && value)
            InkWell(
              onTap: onTimeTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Giờ nhắc nhở: ${_formatTimeOfDay(_reminderTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14, 
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Hàm format thời gian
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Hàm chọn thời gian
  Future<void> _selectTime(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: Colors.blue,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Colors.blue,
                    onSurface: Colors.black,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _reminderTime) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  // Hiển thị dialog xác nhận đặt lại
  void _showResetConfirmDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Đặt lại mặc định?',
            style: TextStyle(color: textColor),
          ),
          content: Text(
            'Tất cả các cài đặt thông báo sẽ được đặt lại về mặc định. Bạn có chắc chắn muốn tiếp tục?',
            style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _resetToDefault();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đặt lại',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Đặt lại cài đặt mặc định
  void _resetToDefault() {
    setState(() {
      _dailyReminder = true;
      _streakReminder = true;
      _commentNotification = true;
      _promotionNotification = false;
      _courseUpdateNotification = true;
      _testReminderNotification = true;
      _achievementNotification = true;
      _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    });

    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đặt lại cài đặt thông báo về mặc định'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
