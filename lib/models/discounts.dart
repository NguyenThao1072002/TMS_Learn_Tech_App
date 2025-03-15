class Discounts {
  final int? id;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final String? description;
  final double? discount_value;
  final DateTime? end_date;
  final bool? is_deleted;
  final DateTime? start_date;
  final String? title;
  final DateTime? updated_at;

  Discounts({
    this.id,
    this.created_at,
    this.deleted_date,
    this.description,
    this.discount_value,
    this.end_date,
    this.is_deleted,
    this.start_date,
    this.title,
    this.updated_at,
  });

  factory Discounts.fromJson(Map<String, dynamic> json) {
    return Discounts(
      id: json['id'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      description: json['description'],
      discount_value: json['discount_value'],
      end_date: json['end_date'],
      is_deleted: json['is_deleted'],
      start_date: json['start_date'],
      title: json['title'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'description': description,
      'discount_value': discount_value,
      'end_date': end_date,
      'is_deleted': is_deleted,
      'start_date': start_date,
      'title': title,
      'updated_at': updated_at,
    };
  }
}
