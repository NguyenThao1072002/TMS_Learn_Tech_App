class Course_reviews {
  final int? id;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final bool? is_deleted;
  final int? rating;
  final String? review;
  final DateTime? updated_at;
  final int? account_id;
  final int? course_id;

  Course_reviews({
    this.id,
    this.created_at,
    this.deleted_date,
    this.is_deleted,
    this.rating,
    this.review,
    this.updated_at,
    this.account_id,
    this.course_id,
  });

  factory Course_reviews.fromJson(Map<String, dynamic> json) {
    return Course_reviews(
      id: json['id'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      is_deleted: json['is_deleted'],
      rating: json['rating'],
      review: json['review'],
      updated_at: json['updated_at'],
      account_id: json['account_id'],
      course_id: json['course_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'is_deleted': is_deleted,
      'rating': rating,
      'review': review,
      'updated_at': updated_at,
      'account_id': account_id,
      'course_id': course_id,
    };
  }
}
