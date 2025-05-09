class PracticeTestCardModel {
  final int testId;
  final String title;
  final String description;
  final int totalQuestion;
  final int courseId;
  final String courseTitle;
  final int itemCountPrice;
  final int itemCountReview;
  final double rating;
  final String imageUrl;
  final String level;
  final String examType;
  final String status;
  final double price;
  final double cost;
  final int percentDiscount;
  final bool purchased;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get vietnameseLevel {
    switch (level.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  PracticeTestCardModel({
    required this.testId,
    required this.title,
    required this.description,
    required this.totalQuestion,
    required this.courseId,
    required this.courseTitle,
    required this.itemCountPrice,
    required this.itemCountReview,
    required this.rating,
    required this.imageUrl,
    required this.level,
    required this.examType,
    required this.status,
    required this.price,
    required this.cost,
    required this.percentDiscount,
    required this.purchased,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PracticeTestCardModel.fromJson(Map<String, dynamic> json) {
    return PracticeTestCardModel(
      testId: json['testId'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      totalQuestion: json['totalQuestion'] as int,
      courseId: json['courseId'] as int,
      courseTitle: json['courseTitle'] as String? ?? '',
      itemCountPrice: json['itemCountPrice'] as int? ?? 0,
      itemCountReview: json['itemCountReview'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      level: json['level'] as String? ?? 'EASY',
      examType: json['examType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      percentDiscount: json['percentDiscount'] as int? ?? 0,
      purchased: json['purchased'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'title': title,
      'description': description,
      'totalQuestion': totalQuestion,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'itemCountPrice': itemCountPrice,
      'itemCountReview': itemCountReview,
      'rating': rating,
      'imageUrl': imageUrl,
      'level': level,
      'examType': examType,
      'status': status,
      'price': price,
      'cost': cost,
      'percentDiscount': percentDiscount,
      'purchased': purchased,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
