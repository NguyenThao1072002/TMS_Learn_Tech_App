/// Model đại diện cho thông báo từ hệ thống
class NotificationItemModel {
  final int id;
  final String? title;
  final String message;
  final NotificationType type;
  final String createdAt;
  bool isRead;

  /// Constructor
  NotificationItemModel({
    required this.id,
    this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  /// Factory tạo đối tượng từ JSON
  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    // Debug log to see what fields are available
    // print('Creating notification from JSON: $json');

    return NotificationItemModel(
      id: json['id'] ?? 0,
      title: json['title'],
      message: json['message'] ?? '',
      type: _mapTopicToType(json['topic'] ?? 'GENERAL'),
      createdAt: json['createdAt'] ?? '',
      // In the API response, status=false means unread (isRead=false)
      // status=true means read (isRead=true)
      isRead: json['status'] ?? json['isRead'] ?? false,
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'topic': _mapTypeToTopic(type),
      'createdAt': createdAt,
      'status': isRead,
    };
  }

  /// Tạo bản sao với một số thuộc tính được thay đổi
  NotificationItemModel copyWith({
    int? id,
    String? title,
    String? message,
    NotificationType? type,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  // Helper method to map API topic to NotificationType
  static NotificationType _mapTopicToType(String topic) {
    switch (topic) {
      case 'PAYMENT':
        return NotificationType.payment;
      case 'LEARNING':
        return NotificationType.study;
      case 'PASSWORD':
        return NotificationType.system;
      case 'ENROLL_COURSE':
        return NotificationType.study;
      case 'GENERAL':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  // Helper method to map NotificationType to API topic
  static String _mapTypeToTopic(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return 'PAYMENT';
      case NotificationType.study:
        return 'LEARNING';
      case NotificationType.system:
        return 'GENERAL';
      case NotificationType.offer:
        return 'OFFER';
      case NotificationType.transfer:
        return 'TRANSFER';
      default:
        return 'GENERAL';
    }
  }
}

// Enum cho các loại thông báo
enum NotificationType {
  payment,
  transfer,
  system,
  offer,
  study,
}
