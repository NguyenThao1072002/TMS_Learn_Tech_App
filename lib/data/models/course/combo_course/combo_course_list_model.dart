import 'package:tms_app/data/models/course/course_card_model.dart';

class ComboCourseModel {
  final int id;
  final String title;
  final String description;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;
  final String imageUrl;
  final String author;
  final bool status;
  final List<CourseCardModel> courses;
  final String? createdAt;
  final String? updatedAt;
  final int? accountId;
  final int numberOfCourses;

  ComboCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.author,
    required this.status,
    required this.courses,
    this.createdAt,
    this.updatedAt,
    this.accountId,
    required this.numberOfCourses,
  });

  factory ComboCourseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse courses list if available
      List<CourseCardModel> courses = [];
      if (json['courses'] != null && json['courses'] is List) {
        courses = (json['courses'] as List)
            .map((course) => CourseCardModel.fromJson(course))
            .toList();
      }

      // Calculate original price and discount if not provided directly
      double originalPrice = _parseDouble(json['originalPrice']) ?? 0.0;
      double salePrice =
          _parseDouble(json['salePrice'] ?? json['price']) ?? 0.0;
      int discountPercent = json['discountPercent'] ?? 0;

      if (originalPrice > 0 &&
          salePrice < originalPrice &&
          discountPercent == 0) {
        // Calculate discount percent if not provided
        discountPercent =
            ((originalPrice - salePrice) / originalPrice * 100).round();
      }

      // Format image URL
      String imageUrl = json['imageUrl'] ?? json['image'] ?? '';
      if (imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http') &&
          !imageUrl.startsWith('assets/')) {
        imageUrl = 'http://103.166.143.198:8080' +
            (imageUrl.startsWith('/') ? '' : '/') +
            imageUrl;
      }

      return ComboCourseModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? json['name'] ?? '',
        description: json['description'] ?? '',
        originalPrice: originalPrice,
        salePrice: salePrice,
        discountPercent: discountPercent,
        imageUrl: imageUrl,
        author: json['author'] ?? json['accountName'] ?? '',
        status: json['status'] ?? true,
        courses: courses,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        accountId: _parseIntOrString(json['accountId']),
        numberOfCourses: json['numberOfCourses'] ?? courses.length,
      );
    } catch (e) {
      // Return a safe default object in case of error
      return ComboCourseModel(
        id: 0,
        title: 'Error loading combo course',
        description: '',
        originalPrice: 0,
        salePrice: 0,
        discountPercent: 0,
        imageUrl: '',
        author: 'Unknown',
        status: false,
        courses: [],
        numberOfCourses: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'salePrice': salePrice,
      'discountPercent': discountPercent,
      'imageUrl': imageUrl,
      'author': author,
      'status': status,
      'courses': courses.map((course) => course.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accountId': accountId,
      'numberOfCourses': numberOfCourses,
    };
  }

  // Helper methods for parsing data
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseIntOrString(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
