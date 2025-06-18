// Models for Chat feature following Clean Architecture pattern

// Model lưu trữ thông tin về hội thoại
class ChatConversationModel {
  final String id;
  final String name;
  final String type; // 'private' hoặc 'group'
  final String fromName;
  final String receivedName;
  final int fromId;
  final int receivedId;
  final String avatarFrom;
  final String avatarReceived;
  final String? fromEmail;
  final String? receivedEmail;
  final List<ChatMessageModel> messages;
  final String lastMessageTimestamp;
  final String roleReceived;
  final String roleSender;

  ChatConversationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.fromName,
    required this.receivedName,
    required this.fromId,
    required this.receivedId,
    required this.avatarFrom,
    required this.avatarReceived,
    this.fromEmail,
    this.receivedEmail,
    required this.messages,
    required this.lastMessageTimestamp,
    required this.roleReceived,
    required this.roleSender,
  });

  // Factory constructor để tạo từ JSON
  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    List<ChatMessageModel> messagesList = [];

    if (json['messages'] != null) {
      messagesList = List<ChatMessageModel>.from((json['messages'] as List)
          .map((message) => ChatMessageModel.fromJson(message)));
    }

    return ChatConversationModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'private',
      fromName: json['fromName'] ?? '',
      receivedName: json['receivedName'] ?? '',
      fromId: json['fromId'] ?? 0,
      receivedId: json['receivedId'] ?? 0,
      avatarFrom: json['avatarFrom'] ?? '',
      avatarReceived: json['avatarReceived'] ?? '',
      fromEmail: json['fromEmail'],
      receivedEmail: json['receivedEmail'],
      messages: messagesList,
      lastMessageTimestamp: json['lastMessageTimestamp'] ?? '',
      roleReceived: json['roleReceived'] ?? '',
      roleSender: json['roleSender'] ?? '',
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'fromName': fromName,
      'receivedName': receivedName,
      'fromId': fromId,
      'receivedId': receivedId,
      'avatarFrom': avatarFrom,
      'avatarReceived': avatarReceived,
      'fromEmail': fromEmail,
      'receivedEmail': receivedEmail,
      'messages': messages.map((message) => message.toJson()).toList(),
      'lastMessageTimestamp': lastMessageTimestamp,
      'roleReceived': roleReceived,
      'roleSender': roleSender,
    };
  }
}

// Model lưu trữ thông tin tin nhắn
class ChatMessageModel {
  final int id;
  final String content;
  final int fromId;
  final int receiveId;
  final String? fromImage;
  final String? receivedImage;
  final String? senderUsername;
  final String timestamp;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.fromId,
    required this.receiveId,
    this.fromImage,
    this.receivedImage,
    this.senderUsername,
    required this.timestamp,
  });

  // Factory constructor để tạo từ JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      fromId: json['fromId'] ?? 0,
      receiveId: json['receiveId'] ?? 0,
      fromImage: json['fromImage'],
      receivedImage: json['receivedImage'],
      senderUsername: json['senderUsername'],
      timestamp: json['timestamp'] ?? '',
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'fromId': fromId,
      'receiveId': receiveId,
      'fromImage': fromImage,
      'receivedImage': receivedImage,
      'senderUsername': senderUsername,
      'timestamp': timestamp,
    };
  }
}

// Model hiển thị cho UI (presentation layer)
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

// Model hiển thị tin nhắn cho UI (presentation layer)
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
