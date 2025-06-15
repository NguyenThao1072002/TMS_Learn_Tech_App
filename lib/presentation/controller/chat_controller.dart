import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/domain/usecases/chat_usecase.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tms_app/presentation/screens/my_account/chat.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import '../../core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';

// Model lưu trữ thông tin về chat cho UI
// class ChatInfo {
// final String id;
// final String name;
// final String type;
// final String fromName;
// final String receiverName;
// final String fromId;
// final String receiverId;
// final String avatarFrom;
// final String avatarReceived;
// final String fromEmail;
// final String receiverEmail;
// final String lastMessage;
// final String lastMessageTime;
// final bool isGroup;
// final int unreadCount;
// final bool isTeacher;

//     final String id;
//   final String name;
//   final String type; // 'private' hoặc 'group'
//   final String fromName;
//   final String receivedName;
//   final int fromId;
//   final int receivedId;
//   final String avatarFrom;
//   final String avatarReceived;
//   final String? fromEmail;
//   final String? receivedEmail;
//   final List<ChatMessageModel> messages;
//   final String lastMessageTimestamp;
//   final String roleReceived;
//   final String roleSender;

//   ChatInfo({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.fromName,
//     required this.receiverName,
//     required this.fromId,
//     required this.receiverId,
//     required this.avatarFrom,
//     required this.avatarReceived,
//     required this.fromEmail,
//     required this.receiverEmail,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     this.isGroup = false,
//     this.unreadCount = 0,
//     this.isTeacher = false,
//   });
// }

// // Model lưu trữ thông tin tin nhắn cho UI
// class ChatMessage {
//   final String id;
//   final String content;
//   final String fromId;
//   final String fromImage;
//   final String receiverId;
//   final String senderUsername;

//   final String receiverImage;
//   final String timestamp;
//   final bool isMe;

//   ChatMessage({
//     required this.id,
//     required this.content,
//     required this.fromId,
//     required this.fromImage,
//     required this.receiverId,
//     required this.senderUsername,
//     required this.receiverImage,
//     required this.timestamp,
//     required this.isMe,
//   });
// }

class ChatController extends GetxController {
  final ChatUsecase? chatUsecase;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final Rx<String?> selectedChatId = Rx<String?>(null);

  // Data containers
  final RxList<ChatConversationModel> chatGroups =
      <ChatConversationModel>[].obs;
  final RxList<ChatConversationModel> privateChats =
      <ChatConversationModel>[].obs;
  final RxMap<String, List<ChatMessageModel>> chatMessages =
      <String, List<ChatMessageModel>>{}.obs;

  ChatController({this.chatUsecase});

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  // Load all conversations from API
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      if (chatUsecase != null) {
        // Gọi API lấy danh sách hội thoại nhóm
        final groupsResult = await chatUsecase!.getGroupConversations();
        if (groupsResult != null && groupsResult.isNotEmpty) {
          chatGroups.clear();
          chatGroups.addAll(groupsResult);
        }

        // Gọi API lấy danh sách hội thoại với giáo viên
        // final userId = await _getCurrentUserId();
        final privateResult = await chatUsecase!.getPrivateConversations();
        // debugPrint('privateResult: ${privateResult}');
        if (privateResult != null && privateResult.isNotEmpty) {
          privateChats.clear();
          privateChats.addAll(privateResult);
          // debugPrint('privateChats: ${privateChats}');
        }

        // Lưu trữ tin nhắn cho mỗi cuộc hội thoại
        await _preloadMessagesFromConversations();
      } else {
        // Nếu không có usecase, sử dụng dữ liệu mẫu cho demo
        //_addSampleData();
      }
    } catch (e) {
      // debugPrint('Exception loading conversations: $e');
      // Nếu có lỗi, vẫn hiển thị dữ liệu mẫu
      if (chatGroups.isEmpty && privateChats.isEmpty) {
        //_addSampleData();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Tải sẵn tin nhắn từ các cuộc hội thoại đã lấy về
  Future<void> _preloadMessagesFromConversations() async {
    try {
      // final userId = await _getCurrentUserId();
      final allConversations = await chatUsecase!.getGroupConversations();

      // int userId = 0;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      for (final conv in allConversations!) {
        // Chuyển đổi tin nhắn sang định dạng UI
        final uiMessages = chatUsecase!
            .mapMessagesForUI(conv, int.tryParse(userId ?? '0') ?? 0);

        // Lưu vào chatMessages
        if (uiMessages.isNotEmpty) {
          chatMessages[conv.id] = uiMessages;
        }
      }
    } catch (e) {
      debugPrint('Error preloading messages: $e');
    }
  }

  // Select a conversation to view
  void selectConversation(String chatId) {
    // Không cần thông báo thay đổi selectedChatId nữa vì đã tách màn hình
    // Chỉ cần cập nhật giá trị để các màn hình khác có thể sử dụng
    selectedChatId.value = chatId;

    // Mark conversation as read
    markAsRead(chatId);

    // Nếu chưa có tin nhắn cho cuộc hội thoại này, tải tin nhắn
    if (!chatMessages.containsKey(chatId) || chatMessages[chatId]!.isEmpty) {
      loadMessages(chatId);
    }
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      if (chatUsecase != null) {
        final userId = await _getCurrentUserId();
        final messages =
            await chatUsecase!.getMessages(conversationId, userId.toString());

        // Chuyển đổi từ ChatMessageModel sang ChatMessage cho UI
        final uiMessages = <ChatMessageModel>[];

        for (final msg in messages) {
          final isMe = msg.fromId == userId;
          uiMessages.add(
            ChatMessageModel(
                id: msg.id,
                content: msg.content,
                fromId: msg.fromId,
                fromImage: msg.fromImage ?? '',
                receiveId: msg.receiveId,
                senderUsername: msg.senderUsername ?? '',
                receivedImage: msg.receivedImage ?? '',
                timestamp: msg.timestamp ?? ''),
          );
        }

        // Cập nhật danh sách tin nhắn
        chatMessages[conversationId] = uiMessages;
      } else {
        // Nếu không có usecase, tin nhắn đã được tải trong _addSampleData
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // Lấy ID người dùng hiện tại
  Future<int> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      if (userId != null) {
        return int.parse(userId);
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return 0; // Giá trị mặc định
  }

  // Format thời gian từ chuỗi timestamp
  String _formatMessageTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return _getCurrentTime();
    } catch (e) {
      return _getCurrentTime();
    }
  }

  // Send a new message
  Future<void> sendMessage(String text) async {
    if (text.isEmpty || selectedChatId.value == null) return;

    final chatId = selectedChatId.value!;
    if (!chatMessages.containsKey(chatId)) {
      chatMessages[chatId] = [];
    }

    try {
      isSending.value = true;

      // Add message to local state first for immediate feedback
      final newMessage = ChatMessageModel(
        id: 0,
        content: text,
        fromId: 0,
        fromImage: '',
        receiveId: 0,
        senderUsername: '',
        receivedImage: '',
        timestamp: _getCurrentTime(),
      );

      chatMessages[chatId]!.add(newMessage);
      chatMessages.refresh(); // Đảm bảo UI được cập nhật

      // Update the last message in the conversation list
      _updateLastMessage(chatId, text);

      // Send message to API if usecase is available
      if (chatUsecase != null) {
        final userId = await _getCurrentUserId();

        // Determine the recipient ID based on the conversation
        int recipientId = 0;

        // Check if it's a group or private chat
        if (chatId.startsWith('g')) {
          // For group chat, we need to get the group ID
          // This is simplified - in a real app you would extract the actual ID
          recipientId = int.tryParse(chatId.substring(1)) ?? 0;
        } else {
          // For private chat, find the chat in privateChats
          final chat = privateChats.firstWhere(
            (c) => c.id == chatId,
            orElse: () => ChatConversationModel(
              id: '',
              name: '',
              type: 'private',
              fromName: '',
              receivedName: '',
              fromId: 0,
              receivedId: 0,
              avatarFrom: '',
              avatarReceived: '',
              fromEmail: '',
              receivedEmail: '',
              lastMessageTimestamp: '',
              messages: [],
              roleReceived: '',
              roleSender: '',
            ),
          );

          // This is simplified - in a real app you would have the recipient ID stored
          recipientId = int.tryParse(chatId.substring(1)) ?? 0;
        }

        if (userId > 0 && recipientId > 0) {
          await chatUsecase!.sendMessage(userId, recipientId, text);
        }
      } else {
        // If no usecase, simulate receiving a response for demo
        // _simulateResponse(chatId);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      isSending.value = false;
    }
  }

  // Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    try {
      // Update local state first
      final isGroup = conversationId.startsWith('g');
      final list = isGroup ? chatGroups : privateChats;

      for (int i = 0; i < list.length; i++) {
        if (list[i].id == conversationId) {
          final updated = ChatConversationModel(
            id: list[i].id,
            name: list[i].name,
            type: list[i].type,
            fromName: list[i].fromName,
            receivedName: list[i].receivedName,
            fromId: list[i].fromId,
            receivedId: list[i].receivedId,
            avatarFrom: list[i].avatarFrom,
            avatarReceived: list[i].avatarReceived,
            fromEmail: list[i].fromEmail,
            receivedEmail: list[i].receivedEmail,
            lastMessageTimestamp: list[i].lastMessageTimestamp,
            messages: list[i].messages,
            roleReceived: list[i].roleReceived,
            roleSender: list[i].roleSender,
          );

          if (isGroup) {
            chatGroups[i] = updated;
          } else {
            privateChats[i] = updated;
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('Exception marking as read: $e');
    }
  }

  // // Simulate response for demo purposes
  // void _simulateResponse(String chatId) {
  //   Future.delayed(const Duration(seconds: 1), () {
  //     // Create response based on chat type
  //     String sender = "";
  //     String avatar = "";
  //     String reply = "";

  //     if (chatId.startsWith('g')) {
  //       // If it's a group, teacher responds
  //       sender = "Nguyễn Văn Hoàng (Giáo viên)";
  //       avatar = "https://i.pravatar.cc/150?img=4";
  //       reply =
  //           "Cảm ơn bạn đã chia sẻ. Tôi sẽ kiểm tra vấn đề này và trả lời bạn sớm nhất.";
  //     } else {
  //       // If it's a private chat with a teacher
  //       try {
  //         final teacher = privateChats.firstWhere((t) => t.id == chatId);
  //         sender = teacher.name;
  //         avatar = teacher.avatar;
  //         reply =
  //             "Cảm ơn bạn đã liên hệ. Tôi sẽ hỗ trợ bạn với vấn đề này trong thời gian sớm nhất.";
  //       } catch (e) {
  //         sender = "Giáo viên";
  //         avatar = "https://i.pravatar.cc/150?img=1";
  //         reply = "Cảm ơn bạn đã liên hệ.";
  //       }
  //     }

  //     chatMessages[chatId]!.add(
  //       ChatMessage(
  //         sender: sender,
  //         text: reply,
  //         time: _getCurrentTime(),
  //         isMe: false,
  //         avatar: avatar,
  //       ),
  //     );

  //     // Đảm bảo UI được cập nhật
  //     chatMessages.refresh();
  //   });
  // }

  // Update the last message in conversation list
  void _updateLastMessage(String chatId, String text) {
    final isGroup = chatId.startsWith('g');
    final list = isGroup ? chatGroups : privateChats;

    for (int i = 0; i < list.length; i++) {
      if (list[i].id == chatId) {
        final updated = ChatConversationModel(
          id: list[i].id,
          name: list[i].name,
          type: list[i].type ?? 'private',
          fromName: list[i].fromName,
          receivedName: list[i].receivedName,
          fromId: list[i].fromId,
          receivedId: list[i].receivedId,
          avatarFrom: list[i].avatarFrom,
          avatarReceived: list[i].avatarReceived,
          fromEmail: list[i].fromEmail,
          receivedEmail: list[i].receivedEmail,
          lastMessageTimestamp: list[i].lastMessageTimestamp,
          messages: list[i].messages,
          roleReceived: list[i].roleReceived,
          roleSender: list[i].roleSender,
        );

        if (isGroup) {
          chatGroups[i] = updated;
        } else {
          privateChats[i] = updated;
        }
        break;
      }
    }
  }

  // Get current time formatted
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? "PM" : "AM";
    return "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";
  }

  // Lấy thông tin chat từ ID
  ChatConversationModel? getChatInfo(String chatId) {
    if (chatId.startsWith('g')) {
      try {
        return chatGroups.firstWhere((chat) => chat.id == chatId);
      } catch (e) {
        return null;
      }
    } else {
      try {
        return privateChats.firstWhere((chat) => chat.id == chatId);
      } catch (e) {
        return null;
      }
    }
  }
}
