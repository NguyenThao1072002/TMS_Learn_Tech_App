class CartItem {
  final int cartId;
  final int cartItemId;
  final int? courseId;
  final int? testId;
  final int? courseBundleId;
  final double price;
  final double cost;
  final int discount;
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
    required this.cost,
    required this.discount,
    required this.name,
    required this.type,
    required this.image,
    required this.timestamp,
  }) : assert(
          (courseId != null && testId == null && courseBundleId == null) ||
              (courseId == null && testId != null && courseBundleId == null) ||
              (courseId == null && testId == null && courseBundleId != null) ||
              (courseId == null && testId == null && courseBundleId == null),
          'Chỉ một trong ba trường courseId, testId và courseBundleId được phép có giá trị khác null',
        );

  // Factory constructor cho course
  factory CartItem.course({
    required int cartId,
    required int cartItemId,
    required int courseId,
    required double price,
    required double cost,
    required int discount,
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
    required double cost,
    required int discount,
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
    required double cost,
    required int discount,
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
    // Kiểm tra và đảm bảo chỉ một trong ba trường có giá trị
    final hasCourseid =
        json.containsKey('courseId') && json['courseId'] != null;
    final hasTestId = json.containsKey('testId') && json['testId'] != null;
    final hasCourseBundleId =
        json.containsKey('courseBundleId') && json['courseBundleId'] != null;

    int? courseId;
    int? testId;
    int? courseBundleId;

    if (hasCourseid) {
      courseId = json['courseId'];
    } else if (hasTestId) {
      testId = json['testId'];
    } else if (hasCourseBundleId) {
      courseBundleId = json['courseBundleId'];
    }

    return CartItem(
      cartId: json['cartId'],
      cartItemId: json['cartItemId'],
      courseId: courseId,
      testId: testId,
      courseBundleId: courseBundleId,
      price: json['price'].toDouble(),
      cost: json['cost'].toDouble(),
      discount: json['discount'],
      name: json['name'],
      type: json['type'],
      image: json['image'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'cartId': cartId,
      'cartItemId': cartItemId,
      'price': price,
      'cost': cost,
      'discount': discount,
      'name': name,
      'type': type,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
    };

    // Chỉ thêm một trong ba trường vào JSON
    if (courseId != null) {
      data['courseId'] = courseId;
    } else if (testId != null) {
      data['testId'] = testId;
    } else if (courseBundleId != null) {
      data['courseBundleId'] = courseBundleId;
    }

    return data;
  }
}
