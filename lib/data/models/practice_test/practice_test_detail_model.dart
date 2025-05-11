import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';

class PracticeTestDetailModel extends PracticeTestCardModel {
  final String? intro;
  final List<String> testContents; // "Bạn sẽ được kiểm tra" items
  final List<String> knowledgeRequirements; // "Yêu cầu kiến thức" items

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
    required String author,
    DateTime? updatedAt,
    this.intro,
    this.testContents = const [],
    this.knowledgeRequirements = const [],
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
          author: author,
        );

  factory PracticeTestDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse test contents and knowledge requirements from JSON
    List<String> parseStringList(dynamic jsonField) {
      if (jsonField == null) return [];
      if (jsonField is String) {
        // If the field is a string, try to parse as JSON or split by commas
        try {
          final String str = jsonField.trim();
          if (str.isEmpty) return [];
          // Check if it's a comma-separated list
          if (str.contains(',')) {
            return str
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          // If it's not comma-separated, treat as a single item
          return [str];
        } catch (e) {
          return [];
        }
      } else if (jsonField is List) {
        // If the field is already a list, map it to strings
        return jsonField
            .map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return [];
    }

    return PracticeTestDetailModel(
      testId: json['testId'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      intro: json['intro'] as String?,
      testContents: parseStringList(json['testContents']),
      knowledgeRequirements: parseStringList(json['knowledgeRequirements']),
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
      author: json['author'] as String? ?? 'Unknown',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['intro'] = intro;
    baseJson['testContents'] = testContents;
    baseJson['knowledgeRequirements'] = knowledgeRequirements;
    return baseJson;
  }
}
