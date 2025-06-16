import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/presentation/controller/chat_controller.dart';
import 'package:tms_app/core/DI/service_locator.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final ChatConversationModel chatInfo;
  final String userId;
  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.chatInfo,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatController _chatController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isDisposed = false;

  // Màu sắc cho theme
  late Color _backgroundColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _dividerColor;
  late Color _inputBackgroundColor;
  late Color _inputBorderColor;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;

    // Khởi tạo ChatController từ GetX hoặc service locator
    try {
      _chatController = Get.find<ChatController>();
    } catch (e) {
      _chatController = sl<ChatController>();
      Get.put(_chatController);
    }

    // Chọn hội thoại hiện tại
    _chatController.selectConversation(widget.chatId);

    // Cuộn xuống cuối trong trường hợp có tin nhắn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _scrollToBottom();
      }
    });
  }

  void _initializeColors(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    _cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    _textColor = isDarkMode ? Colors.white : Colors.black;
    _dividerColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    _inputBackgroundColor = isDarkMode ? Colors.grey[800]! : Colors.grey[50]!;
    _inputBorderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _messageController.dispose();
    _scrollController.dispose();
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
    if (text.isEmpty) return;

    // Gửi tin nhắn qua controller
    _chatController.sendMessage(text);

    // Xóa nội dung input
    _messageController.clear();

    // Hiển thị trạng thái "đang gõ" nếu widget vẫn mounted
    if (!_isDisposed) {
      setState(() {
        _isTyping = true;
      });

      // Cuộn xuống cuối danh sách tin nhắn
      _scrollToBottom();
    }

    // Mô phỏng phản hồi từ hệ thống sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isDisposed) {
        setState(() {
          _isTyping = false;
        });

        // Cuộn xuống cuối danh sách tin nhắn
        _scrollToBottom();
      }
    });
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
        title: _buildChatDetailTitle(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildChatDetailScreen();
      }),
    );
  }

  Widget _buildChatDetailTitle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isGroup = widget.chatInfo.type == 'group';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isGroup ? Colors.orange.shade100 : null,
          backgroundImage: NetworkImage(widget.chatInfo.avatarReceived),
          child: isGroup
              ? Icon(Icons.group, color: Colors.orange, size: 18)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGroup
                    ? "Nhóm: ${widget.chatInfo.name}"
                    : widget.chatInfo.receivedName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _isTyping
                    ? "Đang gõ..."
                    : (isGroup
                        ? "${widget.chatInfo.receivedName}"
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

  Widget _buildChatDetailScreen() {
    final messages = _chatController.chatMessages[widget.chatId] ?? [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Tự động cuộn xuống dưới khi có tin nhắn mới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Tin nhắn
        Expanded(
          child: Container(
            color: _backgroundColor,
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color:
                              isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chưa có tin nhắn. Hãy bắt đầu cuộc trò chuyện!",
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
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
                        // Fix the potential index out of range error with a safe check
                        final prevTimeArr = prevMessage.timestamp.split(' ');
                        final currTimeArr = message.timestamp.split(' ');
                        // Only compare if both arrays have sufficient elements
                        if (prevTimeArr.length > 1 &&
                            currTimeArr.length > 1 &&
                            prevTimeArr[1] != currTimeArr[1]) {
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
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Hôm nay", // Trong thực tế sẽ lấy từ timestamp
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
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
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
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
                  "${widget.chatInfo.type == 'group' ? 'Giáo viên' : 'Người nhận'} đang gõ...",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Divider trước input
        Divider(height: 1, color: _dividerColor),

        // Input tin nhắn
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          color: _backgroundColor,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                onPressed: () {
                  // Chức năng thêm media
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _inputBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _inputBorderColor),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Nhắn tin...",
                      hintStyle: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(color: _textColor),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Container(
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
                    onPressed: _chatController.isSending.value
                        ? null
                        : _handleSendMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessageModel message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isGroup = widget.chatInfo.type == 'group';

    int userId = int.tryParse(widget.userId) ?? 0;
    // If it's a group chat, handle it differently
    if (isGroup) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: message.fromId == userId
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar (only show for messages from others)
            if (message.fromId != userId) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                    message.fromImage?.isNotEmpty == true
                        ? message.fromImage!
                        : "https://ui-avatars.com/api/?name=User"),
              ),
              const SizedBox(width: 12),
            ],

            // Message content
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.fromId == userId
                      ? (isDarkMode
                          ? const Color(0xFF2C2C54)
                          : const Color(0xFFF3F3FF))
                      : (isDarkMode ? Colors.grey[800] : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: message.fromId == userId
                        ? (isDarkMode
                            ? const Color(0xFF3C3C64)
                            : const Color(0xFFE6E6FF))
                        : (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name (only show for messages from others)
                    if (message.fromId != userId) ...[
                      Text(
                        message.senderUsername ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Message content
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        color: _textColor,
                      ),
                    ),

                    // Timestamp
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: message.fromId == userId
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          message.timestamp,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                        if (message.fromId == userId) ...[
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

            // Space after avatar for own messages
            if (message.fromId == userId) const SizedBox(width: 8),
          ],
        ),
      );
    }

    // For non-group chats, use the original code unchanged:
    String avatarToShow = '';
    if (widget.chatInfo.receivedId != widget.userId) {
      avatarToShow = widget.chatInfo.avatarReceived ?? '';
    } else {
      avatarToShow = message.receivedImage ?? '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.fromId == widget.chatInfo.receivedId
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (chỉ hiển thị cho tin nhắn từ người khác)
          if (message.fromId == widget.chatInfo.receivedId) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(avatarToShow?.isNotEmpty ?? false
                  ? avatarToShow!
                  : "https://ui-avatars.com/api/?name=User"),
            ),
            const SizedBox(width: 12),
          ],

          // Nội dung tin nhắn
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.fromId == widget.chatInfo.receivedId
                    ? (isDarkMode
                        ? const Color(0xFF2C2C54)
                        : const Color(0xFFF3F3FF))
                    : (isDarkMode ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: message.fromId == widget.chatInfo.receivedId
                      ? (isDarkMode
                          ? const Color(0xFF3C3C64)
                          : const Color(0xFFE6E6FF))
                      : (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên người gửi (chỉ hiển thị cho tin nhắn từ người khác)
                  if (message.fromId == widget.chatInfo.receivedId) ...[
                    Text(
                      widget.chatInfo.receivedName ?? '',
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
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: _textColor,
                    ),
                  ),

                  // Thời gian
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        message.fromId != widget.chatInfo.receivedId
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                    children: [
                      Text(
                        message.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      if (message.fromId != widget.chatInfo.receivedId) ...[
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
          if (message.fromId != widget.chatInfo.receivedId)
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
