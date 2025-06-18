import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/banner_usecase.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/screens/blog/blog_list.dart';
import 'package:tms_app/presentation/screens/document/document_list_screen.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';
import 'package:tms_app/presentation/widgets/banner/banner_widget.dart';
import 'package:tms_app/presentation/widgets/component/footer.dart';
import 'package:tms_app/presentation/widgets/course/course_categories.dart';
import 'package:tms_app/presentation/widgets/course/discount_courses.dart';
import 'package:tms_app/presentation/widgets/course/popular_courses.dart';
import 'package:tms_app/presentation/widgets/home/home_app_bar.dart';
import 'package:tms_app/presentation/widgets/home/home_discover_widget.dart';
import 'package:tms_app/presentation/widgets/home/home_user_header.dart';
import 'package:tms_app/presentation/widgets/home/teaching_staff_list.dart';
import 'package:tms_app/presentation/widgets/navbar/bottom_navbar_widget.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
// import 'package:tms_app/data/datasources/blog_data.dart';
import '../../controller/home_controller.dart';
import 'package:tms_app/presentation/controller/notification_controller.dart';
import 'package:get/get.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'dart:convert';
import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final List<Widget> _screens;
  late final NotificationController _notificationController;
  OverlayEntry? _overlayEntry;
  final String webSocketUrl = Constants.BASE_URL.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://') + '/ws';
  late StompClient _client;

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _screens = _controller.getScreens(
      HomePage(),
      DocumentListScreen(),
    );

    // Initialize local notifications
    _initLocalNotifications();

    // Initialize notification system
    _initNotifications();
    _initializeWebSocket();
    // Start heartbeat check if needed
    _startHeartbeatCheck();
  }

  void _initializeWebSocket() {
    // Khởi tạo StompClient
    final socket =
        WebSocketChannel.connect(Uri.parse(webSocketUrl));
    _client = StompClient(
      config: StompConfig(
        url: webSocketUrl, // URL WebSocket của bạn
        onConnect: (frame) {
          _client.subscribe(
            destination: '/user/7/queue/notifications',
            callback: (frame) {
              // Khi nhận được tin nhắn từ WebSocket
              final messageBody = frame.body!;
              final newNotification =
                  NotificationItemModel.fromJson(json.decode(messageBody));
             
              setState(() {
                _notificationController.notifications
                    .insert(0, newNotification);
                _notificationController.unreadCount.value++;
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

  // Initialize the local notifications plugin
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Navigate to notification screen when notification is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ),
        );
      },
    );
  }

  void _initNotifications() {
    try {
      // Try to get existing controller
      _notificationController = Get.find<NotificationController>();
    } catch (e) {
      // If not found, get from service locator or create new
      try {
        _notificationController = sl<NotificationController>();
        Get.put(_notificationController, permanent: true);
      } catch (e) {
        print('Creating new NotificationController: $e');
        _notificationController = NotificationController();
        Get.put(_notificationController, permanent: true);
      }
    }

    // Load notifications
    _notificationController.loadNotifications();
  }

  // Show a system notification
  Future<void> _showSystemNotification(
      NotificationItemModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'tms_notifications',
      'TMS Notifications',
      channelDescription: 'Notifications from TMS Learn Tech',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification.id,
      notification.title ?? 'Thông báo mới',
      notification.message,
      platformChannelSpecifics,
    );
  }

  // Show a popup notification when a new notification arrives
  void _showNotificationPopup(NotificationItemModel notification) {
    // Remove any existing overlay
    _removeOverlay();

    // Create a new overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildNotificationPopup(notification),
    );

    // Insert the overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null && mounted) {
        Overlay.of(context)?.insert(_overlayEntry!);

        // Auto-dismiss after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          _removeOverlay();
        });
      }
    });
  }

  // Remove the overlay if it exists
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Build the notification popup widget
  Widget _buildNotificationPopup(NotificationItemModel notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            _removeOverlay();
            // Navigate to notification screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getNotificationTypeColor(notification.type)
                      .withOpacity(0.2),
                  child: Icon(
                    _getNotificationTypeIcon(notification.type),
                    color: _getNotificationTypeColor(notification.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title ?? 'Thông báo mới',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Close button
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                    size: 20,
                  ),
                  onPressed: _removeOverlay,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get icon for notification type
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

  // Get color for notification type
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

  // Start a timer to check WebSocket connection health
  void _startHeartbeatCheck() {
    Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check if WebSocket is still connected
      // _checkWebSocketConnection();
    });
  }

  // Check WebSocket connection and reconnect if needed
  // void _checkWebSocketConnection() {
  //   try {
  //     final wsUrl = Constants.BASE_URL
  //             .replaceFirst('http://', 'ws://')
  //             .replaceFirst('https://', 'wss://') +
  //         '/ws';

  //     // Send a manual ping to check connection
  //     _notificationWebSocket.sendPing();

  //     print('HomeScreen: WebSocket heartbeat check completed');
  //   } catch (e) {
  //     print('HomeScreen: WebSocket connection check failed: $e');
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    // Do not dispose shared NotificationController here – it may be used elsewhere
    _removeOverlay(); // Remove any active overlay
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.selectedIndex,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _screens[index],
          bottomNavigationBar: BottomNavBar(
            selectedIndex: index,
            onTap: _controller.onItemTapped,
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Biến đối tượng của các usecase
  final courseUseCase = GetIt.instance<CourseUseCase>();
  final bannerUseCase = GetIt.instance<BannerUseCase>();
  final blogUseCase = GetIt.instance<BlogUsecase>();

  // Biến lưu trữ các danh sách
  late Future<List<CourseCardModel>> popularCoursesFuture;
  late Future<List<CourseCardModel>> discountCoursesFuture;
  late Future<List<BannerModel>> bannersFuture;
  late Future<List<BlogCardModel>> blogsFuture;

  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData(); // Gọi hàm tải dữ liệu khi khởi tạo
  }

  void _loadData() {
    setState(() {
      hasError = false;
      errorMessage = '';
    });
    popularCoursesFuture =
        courseUseCase.getPopularCourses(); // Khóa học phổ biến
    discountCoursesFuture =
        courseUseCase.getDiscountCourses(); // Khóa học giảm giá
    bannersFuture = bannerUseCase.getBannersByPositionAndPlatform(
        'home', 'mobile'); // Banner
    blogsFuture = blogUseCase.getAllBlogs(); // Blogs
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBarWidget(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadData(); // Tải lại dữ liệu khi kéo màn hình
            });
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tìm kiếm và thông tin người dùng
                const HomeUserHeader(),
                // Khám phá nhanh
                // const HomeDiscoverWidget(),
                // Banner
                FutureBuilder<List<BannerModel>>(
                  future: bannersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('Error loading banners: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final banners = snapshot.data!;
                      return BannerSlider(banners: banners);
                    } else {
                      return const Center(
                          child: Text('No data available for banners'));
                    }
                  },
                ),

                // Đội ngũ của chúng tôi
                const TeachingStaffList(),

                // Danh mục
                const CategoryWidget(),

                // Hiển thị lỗi nếu có
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Không thể tải khóa học: $errorMessage',
                          style: AppStyles.errorText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loadData(); // Cập nhật lại dữ liệu
                            });
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),

                // Khóa học phổ biến
                FutureBuilder<List<CourseCardModel>>(
                  future: popularCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const PopularCourses(courses: [], isLoading: true);
                    } else if (snapshot.hasError) {
                      return PopularCourses(
                        courses: [],
                        error: 'Không thể tải khóa học: ${snapshot.error}',
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final courses = snapshot.data!;
                      return PopularCourses(courses: courses);
                    } else {
                      return const PopularCourses(
                        courses: [],
                        error: 'Không có khóa học phổ biến',
                      );
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.blockSpacing),
                // Khóa học giảm giá
                FutureBuilder<List<CourseCardModel>>(
                  future: discountCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const DiscountCourses(
                          courses: [], isLoading: true);
                    } else if (snapshot.hasError) {
                      return DiscountCourses(
                        courses: [],
                        error: 'Không thể tải khóa học: ${snapshot.error}',
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final courses = snapshot.data!;
                      return DiscountCourses(courses: courses);
                    } else {
                      return const DiscountCourses(
                        courses: [],
                        error: 'Không có khóa học giảm giá',
                      );
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.blockSpacing),

                // Blog Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Blog công nghệ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BlogListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Xem tất cả',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<BlogCardModel>>(
                        future: blogsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Không thể tải bài viết: ${snapshot.error}',
                                style: AppStyles.errorText,
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final featuredBlog =
                                snapshot.data!.first; // Lấy bài viết đầu tiên
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BlogListScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        featuredBlog.image,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 150,
                                            color: isDarkMode
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade200,
                                            child: Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: isDarkMode
                                                    ? Colors.grey.shade600
                                                    : Colors.grey,
                                                size: 50,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            featuredBlog.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.color,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            featuredBlog.sumary,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.8),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: isDarkMode
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade200,
                                                child: Text(
                                                  featuredBlog
                                                          .authorName.isNotEmpty
                                                      ? featuredBlog
                                                          .authorName[0]
                                                          .toUpperCase()
                                                      : "A",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode
                                                        ? Colors.grey.shade300
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                featuredBlog.authorName,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${featuredBlog.views} lượt xem',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
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
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Chưa có bài viết nào",
                                style: AppStyles.subText,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.blockSpacing),

                // Thêm footer vào đây
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
