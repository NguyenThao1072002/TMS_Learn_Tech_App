class Course_discounts {
  final int? id;
  final DateTime? deleted_date;
  final bool? is_deleted;
  final int? course_id;
  final int? discount_id;
  final bool? is_check;

  Course_discounts({
    this.id,
    this.deleted_date,
    this.is_deleted,
    this.course_id,
    this.discount_id,
    this.is_check,
  });

  factory Course_discounts.fromJson(Map<String, dynamic> json) {
    return Course_discounts(
      id: json['id'],
      deleted_date: json['deleted_date'],
      is_deleted: json['is_deleted'],
      course_id: json['course_id'],
      discount_id: json['discount_id'],
      is_check: json['is_check'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deleted_date': deleted_date,
      'is_deleted': is_deleted,
      'course_id': course_id,
      'discount_id': discount_id,
      'is_check': is_check,
    };
  }
}
