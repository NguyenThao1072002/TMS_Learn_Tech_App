import 'package:flutter/foundation.dart';

class CartItem {
  final int cartId;
  final int cartItemId;
  final int? courseId;
  final int? testId;
  final int? courseBundleId;
  final double price;
  final double? cost;
  final int? discount;
  final String name;
  final String type;
  final String image;
  final DateTime timestamp;

  // Constructor chính với validation
  CartItem({
    required this.cartId,
    required this.cartItemId,
    this.courseId,
    this.testId,
    this.courseBundleId,
    required this.price,
    this.cost,
    this.discount,
    required this.name,
    required this.type,
    required this.image,
    required this.timestamp,
  });

  // Factory constructor cho course
  factory CartItem.course({
    required int cartId,
    required int cartItemId,
    required int courseId,
    required double price,
    double? cost,
    int? discount,
    required String name,
    required String type,
    required String image,
    required DateTime timestamp,
  }) {
    return CartItem(
      cartId: cartId,
      cartItemId: cartItemId,
      courseId: courseId,
      price: price,
      cost: cost,
      discount: discount,
      name: name,
      type: type,
      image: image,
      timestamp: timestamp,
    );
  }

  // Factory constructor cho test
  factory CartItem.test({
    required int cartId,
    required int cartItemId,
    required int testId,
    required double price,
    double? cost,
    int? discount,
    required String name,
    required String type,
    required String image,
    required DateTime timestamp,
  }) {
    return CartItem(
      cartId: cartId,
      cartItemId: cartItemId,
      testId: testId,
      price: price,
      cost: cost,
      discount: discount,
      name: name,
      type: type,
      image: image,
      timestamp: timestamp,
    );
  }

  // Factory constructor cho course bundle
  factory CartItem.courseBundle({
    required int cartId,
    required int cartItemId,
    required int courseBundleId,
    required double price,
    double? cost,
    int? discount,
    required String name,
    required String type,
    required String image,
    required DateTime timestamp,
  }) {
    return CartItem(
      cartId: cartId,
      cartItemId: cartItemId,
      courseBundleId: courseBundleId,
      price: price,
      cost: cost,
      discount: discount,
      name: name,
      type: type,
      image: image,
      timestamp: timestamp,
    );
  }

  // Factory constructor từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      // Log để debug
      debugPrint('Parsing CartItem: ${json['name']}, type: ${json['type']}, image: ${json['image']}');
      
      // Xử lý cost có thể null
      double? cost;
      if (json['cost'] != null) {
        cost = (json['cost'] is int) ? (json['cost'] as int).toDouble() : json['cost'].toDouble();
      }
      
      // Xử lý price
      double price;
      if (json['price'] is int) {
        price = (json['price'] as int).toDouble();
      } else {
        price = json['price']?.toDouble() ?? 0.0;
      }
      
      // Xử lý discount có thể null
      int? discount;
      if (json['discount'] != null) {
        discount = json['discount'] is double 
          ? (json['discount'] as double).toInt() 
          : json['discount'];
      }

      return CartItem(
        cartId: json['cartId'],
        cartItemId: json['cartItemId'],
        courseId: json['courseId'],
        testId: json['testId'],
        courseBundleId: json['courseBundleId'],
        price: price,
        cost: cost,
        discount: discount,
        name: json['name'] ?? 'Unknown',
        type: json['type'] ?? 'UNKNOWN',
        image: json['image'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );
    } catch (e) {
      debugPrint('Error parsing CartItem: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'cartId': cartId,
      'cartItemId': cartItemId,
      'price': price,
      'name': name,
      'type': type,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
    };

    // Thêm các trường có thể null
    if (courseId != null) data['courseId'] = courseId;
    if (testId != null) data['testId'] = testId;
    if (courseBundleId != null) data['courseBundleId'] = courseBundleId;
    if (cost != null) data['cost'] = cost; 
    if (discount != null) data['discount'] = discount;

    return data;
  }
}
