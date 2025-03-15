class GeneralDocuments {
  final int id;
  final DateTime createdAt;
  final String description;
  final String image;
  final String title;
  final DateTime updatedAt;
  final String url;
  final int view;
  final int idCategory;
  final DateTime deletedDate;
  final bool isDeleted;
  final bool status;

  GeneralDocuments({
    required this.id,
    required this.createdAt,
    required this.description,
    required this.image,
    required this.title,
    required this.updatedAt,
    required this.url,
    required this.view,
    required this.idCategory,
    required this.deletedDate,
    required this.isDeleted,
    required this.status,
  });

  factory GeneralDocuments.fromJson(Map<String, dynamic> json) {
    return GeneralDocuments(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      image: json['image'],
      title: json['title'],
      updatedAt: DateTime.parse(json['updated_at']),
      url: json['url'],
      view: json['view'],
      idCategory: json['id_category'],
      deletedDate: DateTime.parse(json['deleted_date']),
      isDeleted: json['is_deleted'] == 1,
      status: json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'image': image,
      'title': title,
      'updated_at': updatedAt.toIso8601String(),
      'url': url,
      'view': view,
      'id_category': idCategory,
      'deleted_date': deletedDate.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'status': status ? 1 : 0,
    };
  }
}