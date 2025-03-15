class Categories {
  final int? id_category;
  final int? level;
  final String? name;
  final int? parent_id;
  final DateTime? deleted_date;
  final bool? is_deleted;
  final String? type;

  Categories({
    this.id_category,
    this.level,
    this.name,
    this.parent_id,
    this.deleted_date,
    this.is_deleted,
    this.type,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id_category: json['id_category'],
      level: json['level'],
      name: json['name'],
      parent_id: json['parent_id'],
      deleted_date: json['deleted_date'],
      is_deleted: json['is_deleted'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category': id_category,
      'level': level,
      'name': name,
      'parent_id': parent_id,
      'deleted_date': deleted_date,
      'is_deleted': is_deleted,
      'type': type,
    };
  }
}
