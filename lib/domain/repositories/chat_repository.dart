import 'package:tms_app/data/models/chat/chat_model.dart';

abstract class ChatRepository {
  // Lấy danh sách hội thoại của người dùng
  Future<List<ChatConversationModel>> getConversations(int userId);

  // Gửi tin nhắn mới
  Future<ChatMessageModel> sendMessage(
      int fromId, int receiveId, String content);

  // Đánh dấu tin nhắn là đã đọc
  Future<bool> markAsRead(int messageId);

  // Lấy tin nhắn của một hội thoại
  Future<List<ChatMessageModel>> getMessages(
      String conversationId, String accountId);

  // Tạo hội thoại mới
  Future<ChatConversationModel> createConversation(
      int fromId, int receiveId, String type);

  // Lắng nghe tin nhắn mới từ WebSocket
  Stream<ChatMessageModel> get messageStream;
}
