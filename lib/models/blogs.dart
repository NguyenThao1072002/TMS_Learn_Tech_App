class Blogs {
  final int? id;
  final String? content;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final String? image;
  final bool? is_deleted;
  final bool? status;
  final String? title;
  final DateTime? updated_at;
  final int? author_id;
  final int? cat_blog_id;

  Blogs({
    this.id,
    this.content,
    this.created_at,
    this.deleted_date,
    this.image,
    this.is_deleted,
    this.status,
    this.title,
    this.updated_at,
    this.author_id,
    this.cat_blog_id,
  });

  factory Blogs.fromJson(Map<String, dynamic> json) {
    return Blogs(
      id: json['id'],
      content: json['content'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      image: json['image'],
      is_deleted: json['is_deleted'],
      status: json['status'],
      title: json['title'],
      updated_at: json['updated_at'],
      author_id: json['author_id'],
      cat_blog_id: json['cat_blog_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'image': image,
      'is_deleted': is_deleted,
      'status': status,
      'title': title,
      'updated_at': updated_at,
      'author_id': author_id,
      'cat_blog_id': cat_blog_id,
    };
  }
}
