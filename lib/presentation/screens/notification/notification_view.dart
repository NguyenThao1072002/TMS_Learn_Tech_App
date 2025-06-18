import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:tms_app/core/services/notification_webSocket.dart';
import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:tms_app/presentation/controller/notification_controller.dart';
import 'package:tms_app/presentation/screens/my_account/setting/notification.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late int _userId = 7;
  final String webSocketUrl = Constants.BASE_URL
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://') +
      '/ws';

  late StompClient _client;
  late TabController _tabController;
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize the NotificationController
    _initNotificationController();

    // Configure and connect to WebSocket
    // _setupWebSocket();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Khởi tạo StompClient
    final socket =
        WebSocketChannel.connect(Uri.parse('ws://192.168.1.156:8080/ws'));
    _client = StompClient(
      config: StompConfig(
        url: 'ws://192.168.1.156:8080/ws', // URL WebSocket của bạn
        onConnect: (frame) {
          _client.subscribe(
            destination: '/user/$_userId/queue/notifications',
            callback: (frame) {
              // Khi nhận được tin nhắn từ WebSocket
              final messageBody = frame.body!;
              final newNotification =
                  NotificationItemModel.fromJson(json.decode(messageBody));
              print(messageBody);

              // Cập nhật danh sách thông báo và số lượng chưa đọc
              setState(() {
                _controller.notifications.insert(0, newNotification);
                _controller.unreadCount.value++;
              });
            },
          );
        },
        onWebSocketError: (error) {
          print('WebSocket error: $error');
        },
      ),
    );
    _client.activate();
  }

  void _initNotificationController() {
    try {
      // Try to get the controller from GetX
      _controller = Get.find<NotificationController>();
    } catch (e) {
      // If not found, try to get it from service locator
      try {
        _controller = sl<NotificationController>();
        Get.put(_controller);
      } catch (e) {
        // If still not found, create a new instance
        // print('Creating new NotificationController');
        _controller = NotificationController();
        Get.put(_controller);
      }
    }

    // Load notifications when screen is opened
    _controller.loadNotifications();
  }

  @override
  void dispose() {
    _client.deactivate();
    _controller.dispose();
    super.dispose();
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
            onPressed: () {
              _controller.markAllAsRead();
              _showToast('Đã đánh dấu tất cả là đã đọc');
            },
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
            Obx(() =>
                _buildTab('Quan trọng', _controller.unreadCount.toString())),
            _buildTab(
                'Ưu đãi',
                _controller
                    .getNotificationsByType(NotificationType.offer)
                    .length
                    .toString()),
            _buildTab(
                'Hệ thống',
                _controller
                    .getNotificationsByType(NotificationType.system)
                    .length
                    .toString()),
            _buildTab(
                'Nhắc học',
                _controller
                    .getNotificationsByType(NotificationType.study)
                    .length
                    .toString()),
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

  // Các phương thức khác ở dưới

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
  void _deleteNotification(NotificationItemModel notification) {
    // TODO: Implement delete notification functionality
    _showToast('Đã xóa thông báo');
  }

  // Hiển thị popup tùy chọn cho thông báo
  void _showNotificationOptions(NotificationItemModel notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dividerColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

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
                _controller.markAsRead(notification);
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

  // Widget hiển thị thông báo theo mỗi tab
  Widget _buildNotificationList(NotificationType? filterType) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Lọc thông báo theo loại nếu cần
      final filteredNotifications =
          _controller.getNotificationsByType(filterType);

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
    });
  }

  // Widget để hiển thị một thông báo
  Widget _buildNotificationItem(NotificationItemModel notification) {
    // Lấy trạng thái dark mode từ Theme hiện tại
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Các màu sắc dựa trên dark mode
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final contentColor = isDarkMode ? Colors.grey.shade300 : Colors.black87;
    final timeColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;
    final readIndicatorColor = isDarkMode ? Colors.blue : Colors.pinkAccent;

    // Định dạng lại thời gian
    final formattedTime = _formatTime(notification.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Đánh dấu đã đọc khi nhấn vào
          if (!notification.isRead) {
            _controller.markAsRead(notification);
          }

          // Hiển thị chi tiết thông báo
          _showNotificationDetail(notification);
        },
        onLongPress: () {
          _showNotificationOptions(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biểu tượng loại thông báo
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 12),

              // Nội dung thông báo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tiêu đề thông báo
                        Expanded(
                          child: Text(
                            notification.title ?? 'Thông báo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Thời gian
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Nội dung thông báo
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        notification.message,
                        style: TextStyle(
                          color: contentColor,
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Chỉ báo chưa đọc
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  decoration: BoxDecoration(
                    color: readIndicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Định dạng thời gian hiển thị
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return 'Vừa xong';
    }

    try {
      final dateTime = DateTime.parse(timeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return timeStr; // Trả về nguyên chuỗi nếu không parse được
    }
  }

  // Lấy tên loại thông báo
  String _getNotificationTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return 'Thanh toán';
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

  // Widget cho biểu tượng loại thông báo
  Widget _buildNotificationIcon(NotificationType type) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: _getNotificationTypeColor(type).withOpacity(0.2),
      child: Icon(
        _getNotificationTypeIcon(type),
        color: _getNotificationTypeColor(type),
        size: 22,
      ),
    );
  }

  // Show notification detail popup and mark as read
  void _showNotificationDetail(NotificationItemModel notification) {
    // Mark notification as read
    if (!notification.isRead) {
      _controller.markAsRead(notification);
    }

    // Format date for display
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(notification.createdAt);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      formattedDate = notification.createdAt;
    }

    // Get notification type name and color
    final typeName = _getNotificationTypeName(notification.type);
    final typeColor = _getNotificationTypeColor(notification.type);

    // Show dialog with notification details
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with notification type and close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getNotificationTypeIcon(notification.type),
                      color: typeColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        typeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Notification content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title ?? 'Thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Action button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
