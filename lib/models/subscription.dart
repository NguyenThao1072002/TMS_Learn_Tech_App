class Subscription {
  final int id;
  final DateTime createdAt;
  final DateTime deletedDate;
  final String description;
  final int durationDays;
  final bool isDeleted;
  final String name;
  final double price;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.createdAt,
    required this.deletedDate,
    required this.description,
    required this.durationDays,
    required this.isDeleted,
    required this.name,
    required this.price,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      deletedDate: DateTime.parse(json['deleted_date']),
      description: json['description'],
      durationDays: json['duration_days'],
      isDeleted: json['is_deleted'] == 1,
      name: json['name'],
      price: json['price'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'deleted_date': deletedDate.toIso8601String(),
      'description': description,
      'duration_days': durationDays,
      'is_deleted': isDeleted ? 1 : 0,
      'name': name,
      'price': price,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}