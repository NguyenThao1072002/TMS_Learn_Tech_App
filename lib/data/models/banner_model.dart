class BannerModel {
  final int id;
  final String title;
  final String imageUrl;
  final String link;
  final String position;
  final String platform;
  final String type;
  final String startDate;
  final String endDate;
  final bool status;
  final int priority;
  final String description;
  final String createdAt;
  final String updatedAt;
  final int accountId;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.position,
    required this.platform,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.priority,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'] ?? '',
      position: json['position'] ?? '',
      platform: json['platform'] ?? '',
      type: json['type'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? false,
      priority: json['priority'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      accountId: json['accountId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'position': position,
      'platform': platform,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'priority': priority,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accountId': accountId,
    };
  }
}
