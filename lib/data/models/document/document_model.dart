class DocumentModel {
  final int id;
  final String title;
  final int categoryId;
  final String categoryName;
  final String updatedAt;
  final String createdAt;
  final String format;
  final String size;
  final int view;
  final int downloads;
  final String status;
  final String fileUrl;
  final String description;

  DocumentModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.updatedAt,
    required this.createdAt,
    required this.format,
    required this.size,
    required this.view,
    required this.downloads,
    required this.status,
    required this.fileUrl,
    required this.description,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      format: json['format'] ?? '',
      size: json['size'] ?? '',
      view: json['view'] ?? 0,
      downloads: json['downloads'] ?? 0,
      status: json['status'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'format': format,
      'size': size,
      'view': view,
      'downloads': downloads,
      'status': status,
      'fileUrl': fileUrl,
      'description': description,
    };
  }
}
