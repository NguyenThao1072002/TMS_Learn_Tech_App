class DocumentModel {
  final String id;
  final String title;
  final String type;
  final int pageCount;
  int views;
  int downloads;
  final String? category;
  final String thumbnailUrl;

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.pageCount,
    required this.views,
    required this.downloads,
    this.category,
    required this.thumbnailUrl,
  });

  void increaseViews() {
    views++;
  }

  void incrementDownloads() {
    downloads++;
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? type,
    int? pageCount,
    int? views,
    int? downloads,
    String? category,
    String? thumbnailUrl,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      pageCount: pageCount ?? this.pageCount,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
