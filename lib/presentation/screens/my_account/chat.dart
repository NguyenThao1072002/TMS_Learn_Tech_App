import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';
import 'package:tms_app/presentation/controller/chat_controller.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/presentation/screens/my_account/chat_detail_screen.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChatController _chatController;
  String userId = '';
  // Màu sắc cho theme
  Color _backgroundColor = Colors.white;
  Color _cardColor = Colors.white;
  Color _textColor = Colors.black;
  Color _dividerColor = Colors.grey[200]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Khởi tạo ChatController từ GetX hoặc service locator
    try {
      _chatController = Get.find<ChatController>();
    } catch (e) {
      _chatController = sl<ChatController>();
      Get.put(_chatController);
    }

    // Gọi API để lấy danh sách hội thoại
    _loadConversations();

    // Load user ID
    _loadUserId();
   
  }

  // Load user ID from SharedPrefs
  Future<void> _loadUserId() async {
    final prefs = await SharedPrefs.getSharedPrefs();
    setState(() {
      userId = prefs.getString(SharedPrefs.KEY_USER_ID) ?? '';
    });
  }

  // Hàm gọi API lấy danh sách hội thoại
  Future<void> _loadConversations() async {
    try {
      await _chatController.loadConversations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Không thể tải danh sách hội thoại: ${e.toString()}')),
        );
      }
    }
  }

  void _initializeColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    _cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    _textColor = isDarkMode ? Colors.white : Colors.black;
    _dividerColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToChatDetail(String chatId, ChatConversationModel chatInfo) {
    Get.to(() => ChatDetailScreen(
          chatId: chatId,
          chatInfo: chatInfo,
          userId: userId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    _initializeColors(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        title: const Text("Tin nhắn"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "Nhóm khóa học"),
                Tab(text: "Giáo viên"),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildChatList(_chatController.chatGroups),
            _buildChatList(_chatController.privateChats),
          ],
        );
      }),
    );
  }

  Widget _buildChatList(List<ChatConversationModel> chats) {
    return chats.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  chats == _chatController.chatGroups
                      ? Icons.group
                      : Icons.school,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  chats == _chatController.chatGroups
                      ? "Chưa có nhóm chat nào"
                      : "Chưa có giáo viên nào",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => Divider(
              color: _dividerColor,
              height: 1,
              indent: 80,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatListItem(chat);
            },
          );
  }

  Widget _buildChatListItem(ChatConversationModel chat) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        // Chuyển sang màn hình chi tiết
        _navigateToChatDetail(chat.id, chat);
      },
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(chat.avatarFrom),
            ),
          ),
          if (chat.type == 'group')
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _backgroundColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.group,
                  color: Colors.blue,
                  size: 12,
                ),
              ),
            ),
          if (chat.type == 'group')
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _backgroundColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.orange,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.type == 'group' ? chat.name : chat.receivedName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: _textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.type == 'group'
                ? chat.lastMessageTimestamp
                : chat.lastMessageTimestamp,
            style: TextStyle(
              fontSize: 12,
              // color: chat.u > 0
              //     ? Colors.orange
              //     : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
              // fontWeight:
              //     chat.unread > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.type == 'group'
                  ? chat.lastMessageTimestamp
                  : chat.lastMessageTimestamp,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                // color: chat.unread > 0
                //     ? (isDarkMode ? Colors.grey[200] : Colors.black87)
                //     : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
          // if (chat.unreadCount > 0)
          //   Container(
          //     margin: const EdgeInsets.only(left: 8),
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //     decoration: BoxDecoration(
          //       color: Colors.orange,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Text(
          //       chat.unreadCount.toString(),
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 10,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
