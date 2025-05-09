import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';

class PracticeTestDetailModel extends PracticeTestCardModel {
  final String? intro;

  PracticeTestDetailModel({
    required int testId,
    required String title,
    required String description,
    required int totalQuestion,
    required int courseId,
    required String courseTitle,
    required int itemCountPrice,
    required int itemCountReview,
    required double rating,
    required String imageUrl,
    required String level,
    required String examType,
    required String status,
    required double price,
    required double cost,
    required int percentDiscount,
    required bool purchased,
    required DateTime createdAt,
    DateTime? updatedAt,
    this.intro,
  }) : super(
          testId: testId,
          title: title,
          description: description,
          totalQuestion: totalQuestion,
          courseId: courseId,
          courseTitle: courseTitle,
          itemCountPrice: itemCountPrice,
          itemCountReview: itemCountReview,
          rating: rating,
          imageUrl: imageUrl,
          level: level,
          examType: examType,
          status: status,
          price: price,
          cost: cost,
          percentDiscount: percentDiscount,
          purchased: purchased,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PracticeTestDetailModel.fromJson(Map<String, dynamic> json) {
    return PracticeTestDetailModel(
      testId: json['testId'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      intro: json['intro'] as String?,
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

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['intro'] = intro;
    return baseJson;
  }
}
