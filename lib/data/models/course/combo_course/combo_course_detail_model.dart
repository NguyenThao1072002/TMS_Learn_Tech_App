import 'package:intl/intl.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';

class ComboCourseDetailModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double cost;
  final String imageUrl;
  final List<ComboCourseItem> courses;
  final int discount;
  final String status;
  final int salesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool purchased;

  ComboCourseDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.imageUrl,
    required this.courses,
    required this.discount,
    required this.status,
    required this.salesCount,
    this.createdAt,
    this.updatedAt,
    required this.purchased,
  });

  factory ComboCourseDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse courses list
    List<ComboCourseItem> coursesList = [];
    if (json['courses'] != null) {
      coursesList = List<ComboCourseItem>.from(
        json['courses'].map((course) => ComboCourseItem.fromJson(course)),
      );
    }

    // Parse dates
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (e) {
        print('Error parsing createdAt: $e');
      }
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt']);
      } catch (e) {
        print('Error parsing updatedAt: $e');
      }
    }

    // Calculate real discount if not provided
    int discountValue = json['discount'] ?? 0;
    final double costValue = _parseDouble(json['cost']) ?? 0.0;
    final double priceValue = _parseDouble(json['price']) ?? 0.0;

    if (costValue > priceValue && discountValue == 0) {
      discountValue = ((costValue - priceValue) / costValue * 100).round();
    }

    return ComboCourseDetailModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: priceValue,
      cost: costValue,
      imageUrl: _formatImageUrl(json['imageUrl'] ?? ''),
      courses: coursesList,
      discount: discountValue,
      status: json['status'] ?? 'ACTIVE',
      salesCount: _parseInt(json['salesCount']) ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      purchased: json['purchased'] ?? false,
    );
  }

  // Helper methods for parsing
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;

    return 'http://103.166.143.198:8080' +
        (url.startsWith('/') ? '' : '/') +
        url;
  }

  // Get formatted price with currency
  String getFormattedPrice() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }

  // Get formatted original price with currency
  String getFormattedCost() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(cost);
  }

  // Calculate total original price from all courses
  double getTotalOriginalPrice() {
    return courses.fold(0, (sum, course) => sum + (course.cost));
  }

  // Get formatted total original price
  String getFormattedTotalOriginalPrice() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(getTotalOriginalPrice());
  }

  // Calculate total savings
  double getSavings() {
    double totalCoursesPrice =
        courses.fold(0, (sum, course) => sum + (course.cost));
    return totalCoursesPrice - price;
  }

  // Get formatted savings
  String getFormattedSavings() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(getSavings());
  }
}

class ComboCourseItem {
  final int id;
  final String title;
  final String imageUrl;
  final double price;
  final double cost;
  final String author;
  final bool purchased;
  final int percentDiscount;
  final int lessonCount;
  final int studentCount;
  final int itemCountReview;
  final double rating;
  final String categoryName;
  final int? accountId;
  final String? courseCategoryId;
  final bool deleted;
  final int duration;
  final String type;
  final String level;

  ComboCourseItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.cost,
    required this.author,
    required this.purchased,
    required this.percentDiscount,
    required this.lessonCount,
    required this.studentCount,
    required this.itemCountReview,
    required this.rating,
    required this.categoryName,
    this.accountId,
    this.courseCategoryId,
    required this.deleted,
    required this.duration,
    required this.type,
    required this.level,
  });

  factory ComboCourseItem.fromJson(Map<String, dynamic> json) {
    // Calculate real discount if not provided
    int discountValue = json['percentDiscount'] ?? 0;
    final double costValue = _parseDouble(json['cost']) ?? 0.0;
    final double priceValue = _parseDouble(json['price']) ?? 0.0;

    if (costValue > priceValue && discountValue == 0) {
      discountValue = ((costValue - priceValue) / costValue * 100).round();
    }

    return ComboCourseItem(
      id: _parseInt(json['id']) ?? 0,
      title: json['title'] ?? '',
      imageUrl: _formatImageUrl(json['imageUrl'] ?? ''),
      price: priceValue,
      cost: costValue,
      author: json['author'] ?? '',
      purchased: json['purchased'] ?? false,
      percentDiscount: discountValue,
      lessonCount: _parseInt(json['lessonCount']) ?? 0,
      studentCount: _parseInt(json['studentCount']) ?? 0,
      itemCountReview: _parseInt(json['itemCountReview']) ?? 0,
      rating: _parseDouble(json['rating']) ?? 0.0,
      categoryName: json['categoryName'] ?? '',
      accountId: _parseInt(json['accountId']),
      courseCategoryId: json['courseCategoryId']?.toString(),
      deleted: json['deleted'] ?? false,
      duration: _parseInt(json['duration']) ?? 0,
      type: json['type'] ?? '',
      level: json['level'] ?? '',
    );
  }

  // Helper methods for parsing
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;

    return 'http://103.166.143.198:8080' +
        (url.startsWith('/') ? '' : '/') +
        url;
  }

  // Get formatted price with currency
  String getFormattedPrice() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }

  // Get formatted original price with currency
  String getFormattedCost() {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(cost);
  }

  // Convert ComboCourseItem to CourseCardModel
  CourseCardModel toCardModel() {
    return CourseCardModel(
      id: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      cost: cost,
      discountPercent: percentDiscount,
      author: author,
      courseOutput: "",
      duration: duration,
      language: "Vietnamese",
      status: !deleted,
      type: type,
      categoryName: categoryName,
    );
  }
}
