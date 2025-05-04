import 'package:tms_app/data/models/categories/category_model.dart';

class BlogCategory extends CategoryModel {
  BlogCategory({
    required super.id,
    required super.name,
    required super.level,
    required super.type,
    super.description,
    required super.itemCount,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      type: 'BLOG',
      description: json['description'],
      itemCount: json['itemCount'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    return map;
  }
}
