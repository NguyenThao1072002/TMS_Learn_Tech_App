import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/my_account/setting/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu mẫu cho thông báo
  final List<NotificationItem> _notifications = [
    NotificationItem(
      type: NotificationType.payment,
      title: 'Thanh toán khóa học JAVA thành công',
      content:
          'Bạn đã thực hiện thanh toán thành công cho khóa học JAVA với số tiền 299.000đ. Nhấn để kiểm tra giao dịch ngay bạn nhé.',
      time: '1 giờ trước',
      isRead: false,
    ),
    NotificationItem(
      type: NotificationType.payment,
      title: 'Thanh toán khóa học Flutter & Dart thành công',
      content:
          'Bạn đã thực hiện thanh toán thành công cho khóa học Flutter & Dart với số tiền 499.000đ. Nhấn để kiểm tra giao dịch ngay bạn nhé.',
      time: '18 giờ trước',
      isRead: false,
    ),
    NotificationItem(
      type: NotificationType.transfer,
      title: 'Chuyển tiền/thanh toán thành công',
      content:
          'Bạn đã giao dịch thành công số tiền 45.000đ đến TÀI KHOẢN SINH VIÊN, tài khoản 3326844162.',
      time: '19 giờ trước',
      isRead: true,
    ),
    NotificationItem(
      type: NotificationType.system,
      title: 'Hóa đơn đã đến kỳ thanh toán',
      content:
          'Bạn có hóa đơn học phí cần thanh toán trước ngày 15/03. Vui lòng thanh toán để tránh bị trễ hạn.',
      time: 'Thứ sáu, 07/03',
      isRead: true,
    ),
    NotificationItem(
      type: NotificationType.offer,
      title: 'Giảm giá 50% toàn bộ khóa học',
      content:
          'Chỉ trong tuần này! Giảm giá 50% toàn bộ khóa học dành cho sinh viên. Đừng bỏ lỡ cơ hội nâng cao kỹ năng của bạn.',
      time: 'Thứ tư, 05/03',
      isRead: true,
    ),
    NotificationItem(
      type: NotificationType.study,
      title: 'Nhắc nhở: Bài tập về nhà',
      content:
          'Bạn có bài tập về nhà cần nộp cho khóa học Flutter trước 23:59 hôm nay. Hãy hoàn thành ngay!',
      time: 'Hôm nay, 08:30',
      isRead: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Đếm số thông báo chưa đọc
  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  // Đánh dấu tất cả là đã đọc
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    _showToast('Đã đánh dấu tất cả thông báo là đã đọc');
  }

  // Hiển thị thông báo dạng toast
  void _showToast(String message) {
    // Ẩn snackbar hiện tại nếu có
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Hiển thị toast
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(25),
            color: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Xóa toast sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Xóa thông báo
  void _deleteNotification(NotificationItem notification) {
    setState(() {
      _notifications.remove(notification);
    });
    _showToast('Đã xóa thông báo');
  }

  // Hiển thị popup tùy chọn cho thông báo
  void _showNotificationOptions(NotificationItem notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dividerColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh ngang ở trên cùng
            Container(
              height: 4,
              width: 50,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.blue),
              title: Text(
                'Đánh dấu đã đọc',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  notification.isRead = true;
                });
                _showToast('Đã đánh dấu thông báo là đã đọc');
              },
            ),
            Divider(height: 1, color: dividerColor),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Xoá thông báo',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
            ),
            Divider(height: 1, color: dividerColor),
            ListTile(
              leading: Icon(Icons.close, color: Colors.grey),
              title: Text(
                'Huỷ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị cài đặt thông báo
  void _showNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  // Widget cho switch cài đặt
  Widget _buildSettingSwitch(String title, bool initialValue) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (_) {},
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông báo theo mỗi tab
  Widget _buildNotificationList(NotificationType? filterType) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Lọc thông báo theo loại nếu cần
    final filteredNotifications = filterType == null
        ? _notifications
        : _notifications.where((item) => item.type == filterType).toList();

    final emptyTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 64, color: emptyTextColor),
              const SizedBox(height: 16),
              Text(
                'Không có thông báo nào',
                style: TextStyle(
                  fontSize: 18,
                  color: emptyTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: filteredNotifications.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  // Widget cho từng item thông báo
  Widget _buildNotificationItem(NotificationItem notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? (notification.isRead ? Colors.black : const Color(0xFF1A1A1A)) 
        : (notification.isRead ? Colors.white : Colors.blue.shade50);
    
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final contentColor = isDarkMode ? Colors.grey.shade300 : Colors.black87;
    final metaTextColor = isDarkMode ? Colors.grey.shade500 : Colors.grey;
    
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          // Nội dung thông báo
          ListTile(
            contentPadding: const EdgeInsets.only(
                left: 8.0, right: 16.0, top: 12.0, bottom: 12.0),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor:
                  _getNotificationTypeColor(notification.type).withOpacity(isDarkMode ? 0.2 : 0.1),
              child: Icon(
                _getNotificationTypeIcon(notification.type),
                color: _getNotificationTypeColor(notification.type),
                size: 22,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng đầu tiên: Loại thông báo và thời gian
                Row(
                  children: [
                    // Loại thông báo
                    Text(
                      _getNotificationTypeName(notification.type),
                      style: TextStyle(
                        color: metaTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Dấu chấm đen (bullet)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        "•",
                        style: TextStyle(
                          color: metaTextColor,
                          fontSize: 10,
                        ),
                      ),
                    ),

                    // Thời gian
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: metaTextColor,
                        fontSize: 12,
                      ),
                    ),

                    // Phần còn trống để đẩy nút 3 chấm về bên phải
                    const Spacer(),
                  ],
                ),

                // Khoảng cách
                const SizedBox(height: 4),

                // Tiêu đề thông báo
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                    fontSize: 16,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                notification.content,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 14,
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              // Đánh dấu thông báo là đã đọc khi nhấn vào
              if (!notification.isRead) {
                setState(() {
                  notification.isRead = true;
                });
              }
              // TODO: Xử lý khi nhấn vào thông báo
            },
          ),

          // Nút ba chấm ở góc phải trên cùng
          Positioned(
            top: 8,
            right: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showNotificationOptions(notification),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: metaTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lấy tên loại thông báo
  String _getNotificationTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return 'Điểm thanh toán MoMo';
      case NotificationType.transfer:
        return 'Chuyển tiền';
      case NotificationType.system:
        return 'Hệ thống';
      case NotificationType.offer:
        return 'Ưu đãi';
      case NotificationType.study:
        return 'Nhắc học';
    }
  }

  // Lấy icon theo loại thông báo
  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.transfer:
        return Icons.attach_money;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.study:
        return Icons.school;
    }
  }

  // Lấy màu theo loại thông báo
  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Colors.blue;
      case NotificationType.transfer:
        return Colors.red;
      case NotificationType.system:
        return Colors.orange;
      case NotificationType.offer:
        return Colors.green;
      case NotificationType.study:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái dark mode từ Theme hiện tại
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colors for dark and light mode
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey.shade100;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final tabLabelColor = isDarkMode ? Colors.white : Colors.black;
    final tabUnselectedColor = isDarkMode ? Colors.grey.shade600 : Colors.grey;
    final indicatorColor = isDarkMode ? Colors.blue : Colors.pinkAccent;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: iconColor),
            onPressed: _markAllAsRead,
            tooltip: 'Đánh dấu tất cả là đã đọc',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: iconColor),
            onPressed: _showNotificationSettings,
            tooltip: 'Cài đặt thông báo',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: indicatorColor,
          labelColor: tabLabelColor,
          unselectedLabelColor: tabUnselectedColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            _buildTab('Quan trọng', _unreadCount.toString()),
            _buildTab('Ưu đãi', '5'),
            _buildTab('Hệ thống', '3'),
            _buildTab('Nhắc học', '2'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(null), // Tất cả
          _buildNotificationList(NotificationType.offer), // Ưu đãi
          _buildNotificationList(NotificationType.system), // Hệ thống
          _buildNotificationList(NotificationType.study), // Nhắc học
        ],
      ),
    );
  }

  // Widget cho tab
  Widget _buildTab(String text, String count) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = isDarkMode ? const Color(0xFF2A2D3E) : Colors.orange;
    final badgeTextColor = Colors.white;
    
    return Tab(
      child: Row(
        children: [
          Text(text),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum cho các loại thông báo
enum NotificationType {
  payment,
  transfer,
  system,
  offer,
  study,
}

// Model cho thông báo
class NotificationItem {
  final NotificationType type;
  final String title;
  final String content;
  final String time;
  bool isRead;

  NotificationItem({
    required this.type,
    required this.title,
    required this.content,
    required this.time,
    required this.isRead,
  });
}
