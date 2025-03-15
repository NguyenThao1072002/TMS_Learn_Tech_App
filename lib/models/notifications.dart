class Notifications {
  final int id;
  final DateTime createdAt;
  final DateTime deletedDate;
  final bool isDeleted;
  final String message;
  final String title;
  final String topic;
  final DateTime updatedAt;

  Notifications({
    required this.id,
    required this.createdAt,
    required this.deletedDate,
    required this.isDeleted,
    required this.message,
    required this.title,
    required this.topic,
    required this.updatedAt,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      deletedDate: DateTime.parse(json['deleted_date']),
      isDeleted: json['is_deleted'] == 1,
      message: json['message'],
      title: json['title'],
      topic: json['topic'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'deleted_date': deletedDate.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'message': message,
      'title': title,
      'topic': topic,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}