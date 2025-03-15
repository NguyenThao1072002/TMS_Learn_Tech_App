class Comments {
  final int? id;
  final String? content;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final bool? is_approved;
  final bool? is_deleted;
  final DateTime? updated_at;
  final int? acc_id;
  final int? content_id;
  final int? lesson_id;
  final int? video_id;

  Comments({
    this.id,
    this.content,
    this.created_at,
    this.deleted_date,
    this.is_approved,
    this.is_deleted,
    this.updated_at,
    this.acc_id,
    this.content_id,
    this.lesson_id,
    this.video_id,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      id: json['id'],
      content: json['content'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      is_approved: json['is_approved'],
      is_deleted: json['is_deleted'],
      updated_at: json['updated_at'],
      acc_id: json['acc_id'],
      content_id: json['content_id'],
      lesson_id: json['lesson_id'],
      video_id: json['video_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'is_approved': is_approved,
      'is_deleted': is_deleted,
      'updated_at': updated_at,
      'acc_id': acc_id,
      'content_id': content_id,
      'lesson_id': lesson_id,
      'video_id': video_id,
    };
  }
}
