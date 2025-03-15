import 'package:flutter/material.dart';
import 'package:tms/models/user_notifications.dart';
import 'package:tms/models/notifications.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterValue = "Tất cả";
  List<Notifications> _notifications = [];
  List<UserNotifications> _userNotifications = [];

  bool _isAllRead = false; // Kiểm tra nếu tất cả thông báo đã đọc

  // Danh sách trạng thái của các loại thông báo
  Map<String, bool> _notificationSettings = {
    "Nhắc nhở hàng ngày": true,
    "Nhắc nhở giữ streak": true,
    "Bình luận": true,
    "Nhận ưu đãi": true,
    "Nhận thông báo khác": true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 🎯 Lắng nghe sự kiện thay đổi tab để cập nhật danh sách
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {}); // Gọi lại UI để cập nhật thông báo theo tab
    });

    // Data mẫu
    _notifications = [
      Notifications(
        id: 1,
        title: "Thanh toán khoá học thành công",
        message: "Bạn đã thực hiện thanh toán số tiền 270.000đ.",
        topic: "Thông báo thường",
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        updatedAt: DateTime.now(),
        deletedDate: DateTime.now(),
        isDeleted: false,
      ),
      Notifications(
        id: 2,
        title: "Ưu đãi tháng 3",
        message: "Nhận ngay giảm giá 30% khi thanh toán bằng MoMo.",
        topic: "Ưu đãi",
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now(),
        deletedDate: DateTime.now(),
        isDeleted: false,
      ),
      Notifications(
        id: 3,
        title: "Hoàn thành khoá học",
        message: "Chúc mừng bạn đã hoàn thành khoá java cơ bản.",
        topic: "Thông báo thường",
        createdAt: DateTime.now().subtract(Duration(hours: 19)),
        updatedAt: DateTime.now(),
        deletedDate: DateTime.now(),
        isDeleted: false, // Không bị xóa
      ),
      Notifications(
        id: 4,
        title: "Bình luận bài học",
        message: "Thanh Sơn đã trả lời bình luận của bạn.",
        topic: "Bình luận",
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now(),
        deletedDate: DateTime.now(),
        isDeleted: false,
      ),
    ];

    _userNotifications = [
      UserNotifications(
          id: 1, accountId: 1, notificationId: 1, readStatus: false),
      UserNotifications(
          id: 2, accountId: 1, notificationId: 2, readStatus: true),
      UserNotifications(
          id: 3, accountId: 1, notificationId: 3, readStatus: false),
      UserNotifications(
          id: 4, accountId: 1, notificationId: 4, readStatus: true),
    ];
  }

  // // 🔎 Lọc danh sách thông báo theo `topic`
  // List<Notifications> _filterNotifications(String category) {
  //   return _notifications
  //       .where((notification) =>
  //           notification.topic == category && !notification.isDeleted)
  //       .toList();
  // }
  List<Notifications> _filterNotifications() {
    bool onlyUnread = _filterValue == "Chưa xem";

    // 🎯 Xác định topic dựa vào tab hiện tại
    List<String> topics = ["Tất cả", "Thông báo thường", "Ưu đãi", "Bình luận"];
    String selectedTopic = topics[_tabController.index];

    List<int> unreadNotificationIds = _userNotifications
        .where((userNotif) => !userNotif.readStatus)
        .map((e) => e.notificationId)
        .toList();

    return _notifications.where((notification) {
      bool matchesTopic =
          selectedTopic == "Tất cả" || notification.topic == selectedTopic;
      bool matchesReadStatus =
          !onlyUnread || unreadNotificationIds.contains(notification.id);
      return matchesTopic && matchesReadStatus && !notification.isDeleted;
    }).toList();
  }

  // List<Notifications> _filterNotifications(String category, bool onlyUnread) {
  //   List<int> unreadNotificationIds = _userNotifications
  //       .where((userNotif) => !userNotif.readStatus)
  //       .map((e) => e.notificationId)
  //       .toList();

  //   return _notifications.where((notification) {
  //     bool matchesCategory =
  //         (category == "Tất cả" || notification.topic == category);
  //     bool matchesReadStatus =
  //         onlyUnread ? unreadNotificationIds.contains(notification.id) : true;
  //     return matchesCategory && matchesReadStatus && !notification.isDeleted;
  //   }).toList();
  // }

  // Đánh dấu tất cả thông báo là đã đọc
  void _markAllAsRead() {
    setState(() {
      for (var userNotif in _userNotifications) {
        userNotif.readStatus = true;
      }
    });
  }

  // Hàm mở popup "Cài đặt thông báo"
  void _showNotificationSettingsDialog() {
    // Tạo bản sao trạng thái thông báo để chỉnh sửa trong popup
    Map<String, bool> tempSettings = Map.from(_notificationSettings);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.85, // Tăng chiều rộng popup
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // Nền trắng
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      "Cài đặt thông báo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Danh sách các tùy chọn
                    Column(
                      children: tempSettings.keys.map((key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: tempSettings[key],
                          onChanged: (value) {
                            setStateDialog(() {
                              tempSettings[key] = value!;
                            });
                          },
                          activeColor: Colors.blue, // Màu xanh khi chọn
                          checkColor: Colors.white, // Dấu tích trắng
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 12),

                    // Nút "Đặt lại mặc định" & "Lưu"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              tempSettings.updateAll(
                                  (key, value) => false); // Bỏ chọn hết
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Text("Đặt lại mặc định"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _notificationSettings =
                                  Map.from(tempSettings); // Lưu cài đặt
                            });
                            Navigator.pop(context); // Đóng popup
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                          ),
                          child: Text("Lưu",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Dòng 1: Tiêu đề + Cài đặt**
            AppBar(
              title: Center(
                child: Text(
                  "Thông báo",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: _showNotificationSettingsDialog,
                ),
              ],
            ),
            // Dòng 2: ComboBox + Nút "Đọc tất cả"
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ComboBox (DropdownButton)
                  Container(
                    height: 36,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8), // Giảm padding
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterValue,
                        icon: Icon(Icons.arrow_drop_down,
                            color: Colors.black, size: 20),
                        onChanged: (String? newValue) {
                          setState(() {
                            _filterValue = newValue!;
                          });
                        },
                        items: <String>['Tất cả', 'Chưa xem']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ),

                  // Nút "Đọc tất cả"
                  TextButton(
                    onPressed: _notifications.isEmpty ? null : _markAllAsRead,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Giúp nút chỉ chiếm đúng nội dung
                      children: [
                        Text(
                          "Đọc tất cả",
                          style: TextStyle(
                            color: _notifications.isEmpty
                                ? Colors.grey
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.done,
                          color: _notifications.isEmpty
                              ? Colors.grey
                              : Colors.blue,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // **Dòng 3: TabBar (Loại thông báo)**
            Container(
              margin: EdgeInsets.zero, // Xóa margin nếu có
              padding: EdgeInsets.zero, // Xóa padding nếu có
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  tabAlignment: TabAlignment.start,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(
                      horizontal: 12), // Giảm khoảng cách giữa các tab
                  tabs: [
                    Tab(
                        child: Text("Tất cả (10)",
                            style: TextStyle(fontSize: 14))),
                    Tab(
                        child: Text("Thông báo thường (5)",
                            style: TextStyle(fontSize: 14))),
                    Tab(
                        child:
                            Text("Ưu đãi (3)", style: TextStyle(fontSize: 14))),
                    Tab(
                        child: Text("Bình luận (2)",
                            style: TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // **Nội dung từng tab**
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(),
          _buildNotificationList(),
          _buildNotificationList(),
          _buildNotificationList(),
        ],
      ),
    );
  }

  // Widget danh sách thông báo
  Widget _buildNotificationList() {
    List<Notifications> filteredNotifications = _filterNotifications();

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return ListTile(
          leading: Icon(Icons.notifications,
              color: _userNotifications.any((userNotif) =>
                      userNotif.notificationId == notification.id &&
                      userNotif.readStatus)
                  ? Colors.grey
                  : Colors.blue),
          title: Text(notification.title),
          subtitle: Text(notification.message),
          trailing: _userNotifications.any((userNotif) =>
                  userNotif.notificationId == notification.id &&
                  userNotif.readStatus)
              ? Icon(Icons.done, color: Colors.grey)
              : Icon(Icons.brightness_1, color: Colors.blue, size: 12),
          onTap: () {
            setState(() {
              var userNotif = _userNotifications.firstWhere(
                  (userNotif) => userNotif.notificationId == notification.id,
                  orElse: () => UserNotifications(
                      id: -1,
                      readStatus: false,
                      accountId: 0,
                      notificationId: 0));
              if (userNotif.id != -1) {
                userNotif.readStatus = true;
              }
            });
          },
        );
      },
    );
  }

  // Widget khi không có thông báo nào
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/banners/emptyCourse.png", 
            width: 300,
          ),
          SizedBox(height: 12),
          Text(
            "Chưa có thông báo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Hiện không có thông báo nào để hiển thị.\nHãy kiểm tra lại sau.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
