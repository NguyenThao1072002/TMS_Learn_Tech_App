class CategoryModel {
  final int id;
  final String name;
  final int level;
  final String type;
  final String? description;
  final int itemCount;
  final String status;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.level,
    required this.type,
    this.description,
    required this.itemCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      type: json['type'] ?? '',
      description: json['description'],
      itemCount: json['itemCount'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'type': type,
      'description': description,
      'itemCount': itemCount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
