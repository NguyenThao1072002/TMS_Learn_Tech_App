import 'package:flutter/material.dart';

// Model lưu trữ thông tin về chat
class ChatInfo {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String lastMessageTime;
  final bool isGroup;
  final int unreadCount;
  final bool isTeacher;

  ChatInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isGroup = false,
    this.unreadCount = 0,
    this.isTeacher = false,
  });
}

// Model lưu trữ thông tin tin nhắn
class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;
  final String? avatar;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    this.avatar,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // ID của cuộc trò chuyện đang được chọn
  String? _selectedChatId;
  bool _inChatDetail = false;

  // Danh sách các cuộc trò chuyện
  final List<ChatInfo> _chatGroups = [
    ChatInfo(
      id: 'g1',
      name: 'Flutter Pro Bootcamp',
      avatar:
          'https://ui-avatars.com/api/?name=Flutter&background=2196F3&color=fff',
      lastMessage: 'Giáo viên: Nhớ nộp bài tập trước 23:59 hôm nay nhé',
      lastMessageTime: '10:30 AM',
      isGroup: true,
      unreadCount: 3,
    ),
    ChatInfo(
      id: 'g2',
      name: 'React Native Cơ Bản',
      avatar:
          'https://ui-avatars.com/api/?name=React&background=61DAFB&color=000',
      lastMessage: 'Nguyễn Văn A: Có ai gặp lỗi khi cài đặt không?',
      lastMessageTime: 'Hôm qua',
      isGroup: true,
      unreadCount: 0,
    ),
    ChatInfo(
      id: 'g3',
      name: 'Angular Nâng Cao',
      avatar:
          'https://ui-avatars.com/api/?name=Angular&background=DD0031&color=fff',
      lastMessage: 'Mai Thị B: Cảm ơn mọi người đã giúp đỡ',
      lastMessageTime: 'T3',
      isGroup: true,
      unreadCount: 0,
    ),
  ];

  final List<ChatInfo> _teacherChats = [
    ChatInfo(
      id: 't1',
      name: 'Nguyễn Thị Hương',
      avatar: 'https://i.pravatar.cc/150?img=32',
      lastMessage: 'Bạn đã hoàn thành bài kiểm tra chưa?',
      lastMessageTime: '11:42 AM',
      isTeacher: true,
      unreadCount: 2,
    ),
    ChatInfo(
      id: 't2',
      name: 'Trần Minh Tuấn',
      avatar: 'https://i.pravatar.cc/150?img=12',
      lastMessage: 'Tôi sẽ check bài tập của bạn và phản hồi sớm',
      lastMessageTime: 'Hôm qua',
      isTeacher: true,
      unreadCount: 0,
    ),
    ChatInfo(
      id: 't3',
      name: 'Lê Thị Nga',
      avatar: 'https://i.pravatar.cc/150?img=23',
      lastMessage: 'Chúc mừng bạn đã hoàn thành khóa học!',
      lastMessageTime: 'T4',
      isTeacher: true,
      unreadCount: 0,
    ),
  ];

  // Dữ liệu mẫu cho danh sách tin nhắn
  final Map<String, List<ChatMessage>> _chatMessages = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Khởi tạo dữ liệu tin nhắn mẫu
    _initSampleMessages();
  }

  void _initSampleMessages() {
    // Tạo tin nhắn mẫu cho nhóm Flutter
    _chatMessages['g1'] = [
      ChatMessage(
        sender: "Nguyễn Văn Hoàng (Giáo viên)",
        text: "Chào các bạn, chào mừng đến với khóa học Flutter!",
        time: "10:00 AM",
        isMe: false,
        avatar: "https://i.pravatar.cc/150?img=4",
      ),
      ChatMessage(
        sender: "Nguyễn Văn Hoàng (Giáo viên)",
        text: "Nhớ nộp bài tập trước 23:59 hôm nay nhé",
        time: "10:30 AM",
        isMe: false,
        avatar: "https://i.pravatar.cc/150?img=4",
      ),
      ChatMessage(
        sender: "Bạn",
        text: "Dạ, em sẽ nộp đúng hạn ạ",
        time: "10:32 AM",
        isMe: true,
      ),
      ChatMessage(
        sender: "Trần Thị Hà",
        text: "Thưa thầy, em gặp vấn đề với ListView, có thể giúp em không ạ?",
        time: "10:35 AM",
        isMe: false,
        avatar: "https://i.pravatar.cc/150?img=27",
      ),
    ];

    // Tạo tin nhắn mẫu cho giáo viên Nguyễn Thị Hương
    _chatMessages['t1'] = [
      ChatMessage(
        sender: "Nguyễn Thị Hương",
        text: "Chào bạn, bạn đang học khóa Flutter Pro Bootcamp phải không?",
        time: "11:00 AM",
        isMe: false,
        avatar: "https://i.pravatar.cc/150?img=32",
      ),
      ChatMessage(
        sender: "Bạn",
        text:
            "Dạ đúng rồi cô, em đang gặp vài khó khăn với phần State Management",
        time: "11:15 AM",
        isMe: true,
      ),
      ChatMessage(
        sender: "Nguyễn Thị Hương",
        text:
            "Không sao, bạn có thể xem thêm tài liệu tôi đã gửi trong phần học liệu. Và bạn đã hoàn thành bài kiểm tra chưa?",
        time: "11:42 AM",
        isMe: false,
        avatar: "https://i.pravatar.cc/150?img=32",
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedChatId == null) return;

    if (!_chatMessages.containsKey(_selectedChatId)) {
      _chatMessages[_selectedChatId!] = [];
    }

    setState(() {
      // Thêm tin nhắn của người dùng
      _chatMessages[_selectedChatId!]!.add(
        ChatMessage(
          sender: "Bạn",
          text: text,
          time: _getCurrentTime(),
          isMe: true,
        ),
      );

      // Xóa nội dung input
      _messageController.clear();

      // Hiển thị trạng thái "đang gõ"
      _isTyping = true;
    });

    // Cuộn xuống cuối danh sách tin nhắn
    _scrollToBottom();

    // Mô phỏng phản hồi từ hệ thống sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;

          // Phản hồi từ người nhận
          String sender = "";
          String avatar = "";
          String reply = "";

          if (_selectedChatId!.startsWith('g')) {
            // Nếu là nhóm, giáo viên trả lời
            sender = "Nguyễn Văn Hoàng (Giáo viên)";
            avatar = "https://i.pravatar.cc/150?img=4";
            reply =
                "Cảm ơn bạn đã chia sẻ. Tôi sẽ kiểm tra vấn đề này và trả lời bạn sớm nhất.";
          } else {
            // Nếu là chat riêng với giáo viên
            final teacher =
                _teacherChats.firstWhere((t) => t.id == _selectedChatId);
            sender = teacher.name;
            avatar = teacher.avatar;
            reply =
                "Cảm ơn bạn đã liên hệ. Tôi sẽ hỗ trợ bạn với vấn đề này trong thời gian sớm nhất.";
          }

          _chatMessages[_selectedChatId!]!.add(
            ChatMessage(
              sender: sender,
              text: reply,
              time: _getCurrentTime(),
              isMe: false,
              avatar: avatar,
            ),
          );
        });

        // Cuộn xuống cuối danh sách tin nhắn
        _scrollToBottom();
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? "PM" : "AM";
    return "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: _inChatDetail ? _buildChatDetailTitle() : const Text("Tin nhắn"),
        leading: _inChatDetail
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _inChatDetail = false;
                    _selectedChatId = null;
                  });
                },
              )
            : null,
        bottom: !_inChatDetail
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.grey.shade600,
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
              )
            : null,
      ),
      body: _inChatDetail
          ? _buildChatDetailScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(_chatGroups),
                _buildChatList(_teacherChats),
              ],
            ),
    );
  }

  Widget _buildChatDetailTitle() {
    if (_selectedChatId == null) return const Text("Chat");

    final bool isGroup = _selectedChatId!.startsWith('g');
    final List<ChatInfo> sourceList = isGroup ? _chatGroups : _teacherChats;
    final ChatInfo chatInfo =
        sourceList.firstWhere((chat) => chat.id == _selectedChatId);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(chatInfo.avatar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatInfo.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _isTyping
                    ? "Đang gõ..."
                    : (isGroup
                        ? "${sourceList.length} thành viên"
                        : "Trực tuyến"),
                style: TextStyle(
                  fontSize: 12,
                  color: _isTyping ? Colors.blue : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatList(List<ChatInfo> chats) {
    return chats.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  chats == _chatGroups ? Icons.group : Icons.school,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  chats == _chatGroups
                      ? "Chưa có nhóm chat nào"
                      : "Chưa có giáo viên nào",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade100,
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

  Widget _buildChatListItem(ChatInfo chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        setState(() {
          _inChatDetail = true;
          _selectedChatId = chat.id;
        });

        // Đảm bảo tin nhắn mẫu được tạo nếu chưa có
        if (!_chatMessages.containsKey(chat.id)) {
          _chatMessages[chat.id] = [];
        }

        // Cuộn xuống cuối trong trường hợp có tin nhắn
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      },
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(chat.avatar),
            ),
          ),
          if (chat.isGroup)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
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
          if (chat.isTeacher)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
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
              chat.name,
              style: TextStyle(
                fontWeight:
                    chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.lastMessageTime,
            style: TextStyle(
              fontSize: 12,
              color:
                  chat.unreadCount > 0 ? Colors.orange : Colors.grey.shade500,
              fontWeight:
                  chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                color: chat.unreadCount > 0
                    ? Colors.black87
                    : Colors.grey.shade600,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatDetailScreen() {
    if (_selectedChatId == null) {
      return const Center(child: Text("Vui lòng chọn cuộc trò chuyện"));
    }

    final messages = _chatMessages[_selectedChatId] ?? [];

    return Column(
      children: [
        // Tin nhắn
        Expanded(
          child: Container(
            color: Colors.white,
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chưa có tin nhắn. Hãy bắt đầu cuộc trò chuyện!",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      // Xác định xem có cần hiển thị ngày không
                      bool showDate = index == 0;
                      if (index > 0) {
                        final prevMessage = messages[index - 1];
                        // Đây chỉ là mẫu - trong thực tế bạn sẽ so sánh timestamp thực
                        if (prevMessage.time.split(' ')[1] !=
                            message.time.split(' ')[1]) {
                          showDate = true;
                        }
                      }

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Hôm nay", // Trong thực tế sẽ lấy từ timestamp
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          _buildMessageItem(message),
                        ],
                      );
                    },
                  ),
          ),
        ),

        // Đang gõ indicator
        if (_isTyping)
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${_selectedChatId!.startsWith('g') ? 'Giáo viên' : 'Người nhận'} đang gõ...",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Divider trước input
        Divider(height: 1, color: Colors.grey.shade200),

        // Input tin nhắn
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon:
                    Icon(Icons.add_circle_outline, color: Colors.grey.shade700),
                onPressed: () {
                  // Chức năng thêm media
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Nhắn tin...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _handleSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (chỉ hiển thị cho tin nhắn từ người khác)
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  message.avatar ?? "https://ui-avatars.com/api/?name=User"),
            ),
            const SizedBox(width: 12),
          ],

          // Nội dung tin nhắn
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(
                        0xFFF3F3FF) // Màu nhẹ cho tin nhắn của người dùng
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: message.isMe
                      ? const Color(
                          0xFFE6E6FF) // Viền nhẹ cho tin nhắn của người dùng
                      : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên người gửi (chỉ hiển thị cho tin nhắn từ người khác)
                  if (!message.isMe) ...[
                    Text(
                      message.sender,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Nội dung tin nhắn
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),

                  // Thời gian
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: message.isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Khoảng trống sau avatar cho tin nhắn của mình
          if (message.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
