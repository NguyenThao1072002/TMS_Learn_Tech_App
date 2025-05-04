import 'package:tms_app/data/models/categories/category_model.dart';

class DocumentCategory extends CategoryModel {
  DocumentCategory({
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

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      type: 'DOCUMENT',
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
