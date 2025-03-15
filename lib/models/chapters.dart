class Chapters {
  final int? id;
  final String? chapter_title;
  final int? course_id;
  final DateTime? deleted_date;
  final bool? is_deleted;
  final bool? status;

  Chapters({
    this.id,
    this.chapter_title,
    this.course_id,
    this.deleted_date,
    this.is_deleted,
    this.status,
  });

  factory Chapters.fromJson(Map<String, dynamic> json) {
    return Chapters(
      id: json['id'],
      chapter_title: json['chapter_title'],
      course_id: json['course_id'],
      deleted_date: json['deleted_date'],
      is_deleted: json['is_deleted'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_title': chapter_title,
      'course_id': course_id,
      'deleted_date': deleted_date,
      'is_deleted': is_deleted,
      'status': status,
    };
  }
}
