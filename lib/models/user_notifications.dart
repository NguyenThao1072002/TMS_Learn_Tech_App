class UserNotifications {
  int id;
  bool readStatus;
  int accountId;
  int notificationId;

  UserNotifications({
    required this.id,
    required this.readStatus,
    required this.accountId,
    required this.notificationId,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) {
    return UserNotifications(
      id: json['id'],
      readStatus: json['read_status'] == 1,
      accountId: json['account_id'],
      notificationId: json['notification_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'read_status': readStatus ? 1 : 0,
      'account_id': accountId,
      'notification_id': notificationId,
    };
  }
}
