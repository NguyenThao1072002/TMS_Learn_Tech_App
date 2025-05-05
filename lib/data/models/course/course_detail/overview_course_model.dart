class OverviewCourseModel {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? language;
  final String author;
  final String courseOutput;
  final double cost;
  final double price;
  final int duration;
  final String type;
  final bool? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedDate;
  final bool deleted;
  final String accountId;
  final String courseCategoryId;
  final String categoryName;
  final int studentCount;
  final double rating;
  final String? level;
  final String? certificate;

  String get vietnameseLevel {
    switch (level?.toUpperCase()) {
      case 'BEGINNER':
        return 'Sơ cấp';
      case 'INTERMEDIATE':
        return 'Trung cấp';
      case 'ADVANCED':
        return 'Nâng cao';
      default:
        return level ?? 'Sơ cấp';
    }
  }

  OverviewCourseModel(
      {required this.id,
      required this.title,
      this.description,
      required this.imageUrl,
      this.language,
      required this.author,
      required this.courseOutput,
      required this.cost,
      required this.price,
      required this.duration,
      required this.type,
      this.status,
      required this.createdAt,
      this.updatedAt,
      this.deletedDate,
      required this.deleted,
      required this.accountId,
      required this.courseCategoryId,
      required this.categoryName,
      required this.studentCount,
      required this.rating,
      this.level,
      this.certificate});

  factory OverviewCourseModel.fromJson(Map<String, dynamic> json) {
    return OverviewCourseModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      language: json['language'] as String?,
      author: json['author'] as String? ?? '',
      courseOutput: json['courseOutput'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      status: json['status'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'])
          : null,
      deleted: json['deleted'] as bool? ?? false,
      accountId: json['accountId'] as String? ?? '',
      courseCategoryId: json['courseCategoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      studentCount: json['studentCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String?,
      certificate: json['certificate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'language': language,
      'author': author,
      'courseOutput': courseOutput,
      'cost': cost,
      'price': price,
      'duration': duration,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedDate': deletedDate?.toIso8601String(),
      'deleted': deleted,
      'accountId': accountId,
      'courseCategoryId': courseCategoryId,
      'categoryName': categoryName,
      'studentCount': studentCount,
      'rating': rating,
      'level': level,
      'certificate': certificate
    };
  }
}
