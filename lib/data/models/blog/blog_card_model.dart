class BlogCardModel {
  final String id;
  final String title;
  final String content;
  final String sumary;
  final String authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool status;
  final bool featured;
  final String cat_blog_id;
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
      id: json['id'] ?? "",
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sumary: json['summary'] ?? '',
      authorId: json['author_id'] ?? "",
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'] ?? false,
      featured: json['featured'] ?? false,
      cat_blog_id: json['cat_blog_id'] ?? "",
      image: json['image'] ?? '',
      views: json['views'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'])
          : null,
      catergoryName: json['categoryName'] ?? '',
      authorName: json['authorName'] ?? '',
      deleted: json['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': sumary,
      'author_id': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'featured': featured,
      'cat_blog_id': cat_blog_id,
      'image': image,
      'views': views,
      'commentCount': commentCount,
      'deletedDate': deletedDate?.toIso8601String(),
      'categoryName': catergoryName,
      'authorName': authorName,
      'deleted': deleted,
    };
  }

  // Tạo bản sao với một số thuộc tính được thay đổi
  BlogCardModel copyWith({
    String? id,
    String? title,
    String? content,
    String? sumary,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? status,
    bool? featured,
    String? cat_blog_id,
    String? image,
    int? views,
    int? commentCount,
    DateTime? deletedDate,
    String? catergoryName,
    String? authorName,
    bool? deleted,
  }) {
    return BlogCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sumary: sumary ?? this.sumary,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      featured: featured ?? this.featured,
      cat_blog_id: cat_blog_id ?? this.cat_blog_id,
      image: image ?? this.image,
      views: views ?? this.views,
      commentCount: commentCount ?? this.commentCount,
      deletedDate: deletedDate ?? this.deletedDate,
      catergoryName: catergoryName ?? this.catergoryName,
      authorName: authorName ?? this.authorName,
      deleted: deleted ?? this.deleted,
    );
  }
}
