class Courses {
  final int? id;
  final String? author;
  final double? cost;
  final String? course_output;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final String? description;
  final String? duration;
  final String? image_url;
  final bool? is_deleted;
  final String? language;
  final double? price;
  final bool? status;
  final String? courses_title;
  final String? type;
  final DateTime? updated_at;
  final int? course_category_id;
  final int? account_id;

  Courses({
    this.id,
    this.author,
    this.cost,
    this.course_output,
    this.created_at,
    this.deleted_date,
    this.description,
    this.duration,
    this.image_url,
    this.is_deleted,
    this.language,
    this.price,
    this.status,
    this.courses_title,
    this.type,
    this.updated_at,
    this.course_category_id,
    this.account_id,
  });

  factory Courses.fromJson(Map<String, dynamic> json) {
    return Courses(
      id: json['id'],
      author: json['author'],
      cost: json['cost'],
      course_output: json['course_output'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      description: json['description'],
      duration: json['duration'],
      image_url: json['image_url'],
      is_deleted: json['is_deleted'],
      language: json['language'],
      price: json['price'],
      status: json['status'],
      courses_title: json['courses_title'],
      type: json['type'],
      updated_at: json['updated_at'],
      course_category_id: json['course_category_id'],
      account_id: json['account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'cost': cost,
      'course_output': course_output,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'description': description,
      'duration': duration,
      'image_url': image_url,
      'is_deleted': is_deleted,
      'language': language,
      'price': price,
      'status': status,
      'courses_title': courses_title,
      'type': type,
      'updated_at': updated_at,
      'course_category_id': course_category_id,
      'account_id': account_id,
    };
  }
}
