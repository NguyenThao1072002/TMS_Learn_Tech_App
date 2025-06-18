import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';
import 'package:tms_app/domain/repositories/chat_repository.dart';

class ChatUsecase {
  final ChatRepository repository;

  ChatUsecase({required this.repository});

  // Lấy danh sách hội thoại của người dùng
  // Future<List<ChatConversationModel>> getConversations(int userId) async {
  //   return await repository.getConversations(userId);
  // }

  // Lấy danh sách hội thoại nhóm
  Future<List<ChatConversationModel>?> getGroupConversations() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return null;

      final conversations = await repository.getConversations(userId);
      return conversations
          .where((conv) => conv.type.toLowerCase() == 'group')
          .map((conv) => conv)
          .toList();
    } catch (e) {
      print('Error getting group conversations: $e');
      return null;
    }
  }

  // Lấy danh sách hội thoại với giáo viên (private)
  Future<List<ChatConversationModel>?> getPrivateConversations() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return null;

      final conversations = await repository.getConversations(userId);
      // debugPrint('conversations: ${conversations}');
      return conversations
          .where((conv) => conv.type.toLowerCase() == 'private')
          .map((conv) => conv)
          .toList();
    } catch (e) {
      print('Error getting private conversations: $e');
      return null;
    }
  }

  // // // Chuyển đổi từ ChatConversationModel sang ChatInfo cho nhóm chat
  // // controller.ChatInfo _mapToGroupChatInfo(
  // //     ChatConversationModel conv, int userId) {
  // //   // Lấy tin nhắn cuối cùng nếu có
  // //   String lastMessage = '';
  // //   String lastMessageTime = '';

  // //   if (conv.messages.isNotEmpty) {
  // //     final lastMsg = conv.messages.last;
  // //     lastMessage =
  // //         '${lastMsg.senderUsername ?? 'Người dùng'}: ${lastMsg.content}';
  // //     lastMessageTime = _formatTime(DateTime.tryParse(lastMsg.timestamp));
  // //   }

  // //   return controller.ChatInfo(
  // //     id: conv.id,
  // //     name: conv.name,
  // //     type: conv.type,
  // //     fromName: conv.fromName,
  // //     receiverName: conv.receivedName,
  // //     fromId: conv.fromId.toString(),
  // //     receiverId: conv.receivedId.toString(),
  // //     avatarFrom: conv.avatarFrom,
  // //     avatarReceived: conv.avatarReceived,
  // //     fromEmail: conv.fromEmail ?? '',
  // //     receiverEmail: conv.receivedEmail ?? '',
  // //     lastMessage: lastMessage,
  // //     lastMessageTime: lastMessageTime,
  // //     isGroup: true,
  // //     unreadCount: _countUnreadMessages(conv, userId),
  // //   );
  // // }

  // // Chuyển đổi từ ChatConversationModel sang ChatInfo cho chat riêng tư
  // controller.ChatInfo _mapToPrivateChatInfo(
  //     ChatConversationModel conv, int userId) {
  //   // Xác định xem người dùng đang chat với ai
  //   final bool isSender = conv.fromId == userId;
  //   final String name = isSender ? conv.receivedName : conv.fromName;
  //   final String avatar = isSender ? conv.avatarReceived : conv.avatarFrom;

  //   // Lấy tin nhắn cuối cùng nếu có
  //   String lastMessage = '';
  //   String lastMessageTime = '';

  //   if (conv.messages.isNotEmpty) {
  //     final lastMsg = conv.messages.last;
  //     final bool isMyMessage = lastMsg.fromId == userId;
  //     lastMessage = isMyMessage ? 'Bạn: ${lastMsg.content}' : lastMsg.content;
  //     lastMessageTime = _formatTime(DateTime.tryParse(lastMsg.timestamp));
  //   }

  //   return controller.ChatInfo(
  //     id: conv.id,
  //     name: name,
  //     type: conv.type,
  //     fromName: conv.fromName,
  //     receiverName: conv.receivedName,
  //     fromId: conv.fromId.toString(),
  //     receiverId: conv.receivedId.toString(),
  //     avatarFrom: avatar.isNotEmpty
  //         ? avatar
  //         : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}',
  //     avatarReceived: avatar.isNotEmpty
  //         ? avatar
  //         : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}',
  //     fromEmail: conv.fromEmail ?? '',
  //     receiverEmail: conv.receivedEmail ?? '',
  //     lastMessageTimestamp: conv.lastMessageTimestamp,
  //     lastMessage: lastMessage,
  //     // lastMessageTime: lastMessageTime,
  //     isGroup: conv.type == 'group' ? true : false,
  //     unreadCount: _countUnreadMessages(conv, userId),
  //     isTeacher: conv.roleReceived == 'ADMIN' || conv.roleReceived == 'TEACHER',
  //   );
  // }

  // Đếm số tin nhắn chưa đọc
  int _countUnreadMessages(ChatConversationModel conv, int userId) {
    // Đây chỉ là giả định, cần thay thế bằng logic thực tế
    // Thông thường cần một trường isRead trong ChatMessageModel
    return 0;
  }

  // Gửi tin nhắn mới
  Future<ChatMessageModel> sendMessage(
      int fromId, int receiveId, String content) async {
    return await repository.sendMessage(fromId, receiveId, content);
  }

  // Đánh dấu tin nhắn là đã đọc
  Future<bool> markAsRead(int messageId) async {
    return await repository.markAsRead(messageId);
  }

  // Lấy tin nhắn của một hội thoại
  Future<List<ChatMessageModel>> getMessages(
      String conversationId, String accountId) async {
    return await repository.getMessages(conversationId, accountId);
  }

  // Tạo hội thoại mới
  Future<ChatConversationModel> createConversation(
      int fromId, int receiveId, String type) async {
    return await repository.createConversation(fromId, receiveId, type);
  }

  // Lắng nghe tin nhắn mới từ WebSocket
  Stream<ChatMessageModel> get messageStream => repository.messageStream;

  // Lấy ID người dùng hiện tại từ SharedPreferences
  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      return int.tryParse(userId ?? '');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // Format thời gian tin nhắn
  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      // Nếu là hôm nay, hiển thị giờ:phút
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
    } else {
      // Nếu là ngày khác, hiển thị ngày/tháng
      return '${time.day}/${time.month}';
    }
  }

  // Chuyển đổi tin nhắn từ API sang định dạng UI
  List<ChatMessageModel> mapMessagesForUI(
      ChatConversationModel conv, int userId) {
    final messages = <ChatMessageModel>[];

    for (final msg in conv.messages) {
      messages.add(
        ChatMessageModel(
          id: msg.id,
          content: msg.content,
          fromId: msg.fromId,
          fromImage: msg.fromImage ?? '',
          receiveId: msg.receiveId,
          senderUsername: msg.senderUsername ?? '',
          receivedImage: msg.receivedImage ?? '',
          timestamp: msg.timestamp ?? '',
        ),
      );
    }

    return messages;
  }
}
