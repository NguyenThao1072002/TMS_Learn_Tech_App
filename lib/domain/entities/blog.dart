class Blog {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String author;
  final String authorAvatar;
  final String category;
  final DateTime publishDate;
  final int readTime;
  final int views;
  final List<String> tags;

  Blog({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.publishDate,
    required this.readTime,
    required this.views,
    required this.tags,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      author: json['author'],
      authorAvatar: json['authorAvatar'],
      category: json['category'],
      publishDate: DateTime.parse(json['publishDate']),
      readTime: json['readTime'],
      views: json['views'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'authorAvatar': authorAvatar,
      'category': category,
      'publishDate': publishDate.toIso8601String(),
      'readTime': readTime,
      'views': views,
      'tags': tags,
    };
  }
}
