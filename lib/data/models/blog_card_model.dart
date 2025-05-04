class BlogCardModel {
  final int id;
  final String title;
  final String content;
  final String sumary;
  final int authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool status;
  final bool featured;
  final int cat_blog_id;
  final String image;
  final int views;
  final int commentCount;
  final DateTime? deletedDate;
  final String catergoryName;
  final String authorName;
  final bool deleted;

  BlogCardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.sumary,
    required this.authorId,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.featured,
    required this.cat_blog_id,
    required this.image,
    required this.views,
    required this.commentCount,
    this.deletedDate,
    required this.catergoryName,
    required this.authorName,
    required this.deleted,
  });

  factory BlogCardModel.fromJson(Map<String, dynamic> json) {
    return BlogCardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sumary: json['sumary'] ?? '',
      authorId: json['author_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      status: json['status'] ?? false,
      featured: json['featured'] ?? false,
      cat_blog_id: json['cat_blog_id'] ?? 0,
      image: json['image'] ?? '',
      views: json['views'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      deletedDate: json['deleted_date'] != null ? DateTime.parse(json['deleted_date']) : null,
      catergoryName: json['catergory_name'] ?? '',
      authorName: json['author_name'] ?? '',
      deleted: json['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'sumary': sumary,
      'author_id': authorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
      'featured': featured,
      'cat_blog_id': cat_blog_id,
      'image': image,
      'views': views,
      'comment_count': commentCount,
      'deleted_date': deletedDate?.toIso8601String(),
      'catergory_name': catergoryName,
      'author_name': authorName,
      'deleted': deleted,
    };
  }
}
