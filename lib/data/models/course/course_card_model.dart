class CourseCardModel {
  final int id;
  final String title;
  final String imageUrl;
  final double price;
  final double cost;
  int numberOfStudents;
  int totalLessons;
  double averageRating;
  final String author;
  final String courseOutput;
  final String description;
  final int duration;
  final String language;
  final bool status;
  final String type;
  final String? oldPrice;
  final String categoryName;
  int discountPercent;
  final int? idDanhmuc;
  final String? accountId;
  final String? courseCategoryId;
  final bool? deleted;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedDate;
  final bool? isCombo;

  int get categoryId =>
      idDanhmuc ??
      (courseCategoryId != null ? int.tryParse(courseCategoryId!) ?? 0 : 0);

  CourseCardModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.cost,
    this.numberOfStudents = 0,
    this.totalLessons = 0,
    this.averageRating = 0.0,
    required this.author,
    required this.courseOutput,
    this.description = "",
    required this.duration,
    required this.language,
    required this.status,
    required this.type,
    this.oldPrice,
    required this.categoryName,
    this.discountPercent = 0,
    this.idDanhmuc,
    this.accountId,
    this.courseCategoryId,
    this.deleted,
    this.createdAt,
    this.updatedAt,
    this.deletedDate,
    this.isCombo,
  });

  double? get oldPriceAsDouble {
    if (oldPrice == null) return null;
    return double.tryParse(oldPrice!);
  }

  factory CourseCardModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] ?? 0;
      final title = json['title'] ?? json['name'] ?? '';

      // Xử lý URL ảnh: ưu tiên các trường chứa URL ảnh
      String imageUrl =
          json['imageUrl'] ?? json['image'] ?? json['thumbnail'] ?? '';

      // Đảm bảo URL ảnh đầy đủ
      if (imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http') &&
          !imageUrl.startsWith('assets/')) {
        // Nếu là đường dẫn tương đối từ API, thêm domain vào
        imageUrl = 'http://103.166.143.198:8080' +
            (imageUrl.startsWith('/') ? '' : '/') +
            imageUrl;
      }

      // Số lượng học viên
      final studentsCount = json['studentCount'] ??
          json['students'] ??
          json['numberOfStudents'] ??
          0;

      // Số lượng bài học
      final lessonsCount =
          json['lessonCount'] ?? json['lessons'] ?? json['totalLessons'] ?? 0;

      // Đánh giá
      final rating =
          json['rating'] ?? json['averageRating'] ?? json['rate'] ?? 0.0;

      // Giá
      final price = _parseDouble(json['price']) ?? 0.0;
      final cost = _parseDouble(json['cost']) ?? price;

      // Phần trăm giảm giá
      final discountPercent = json['percentDiscount'] ??
          json['discountPercent'] ??
          json['discount'] ??
          0;

      // Kiểm tra xem khóa học có phải combo không
      final isCombo = json['isCombo'] ?? json['is_combo'] ?? false;

      return CourseCardModel(
        id: id,
        title: title,
        imageUrl: imageUrl,
        price: price,
        cost: cost,
        numberOfStudents: studentsCount,
        totalLessons: lessonsCount,
        averageRating: rating is double ? rating : rating.toDouble(),
        author: json['author'] ?? '',
        courseOutput: json['courseOutput'] ?? json['description'] ?? '',
        description: json['description'] ?? '',
        duration: json['duration'] ?? 0,
        language: json['language'] ?? 'Vietnamese',
        status: json['status'] ?? true,
        type: json['type'] ?? 'FREE',
        oldPrice: json['oldPrice']?.toString(),
        categoryName: json['categoryName'] ?? json['category'] ?? '',
        discountPercent: discountPercent,
        idDanhmuc:
            _parseIntOrString(json['courseCategoryId'] ?? json['categoryId']),
        accountId: json['accountId'] ?? json['userId']?.toString(),
        courseCategoryId:
            json['courseCategoryId'] ?? json['categoryId']?.toString(),
        deleted: json['deleted'] ?? false,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        deletedDate: json['deletedDate'],
        isCombo: isCombo,
      );
    } catch (e) {
      // Tạo một đối tượng với giá trị mặc định an toàn
      return CourseCardModel(
        id: 0,
        title: 'Error loading course',
        imageUrl: '',
        price: 0,
        cost: 0,
        author: 'Unknown',
        courseOutput: '',
        duration: 0,
        language: '',
        status: false,
        type: '',
        categoryName: '',
      );
    }
  }

  // Phương thức hỗ trợ để parse giá trị double từ nhiều kiểu dữ liệu
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Phương thức hỗ trợ để parse giá trị int từ nhiều kiểu dữ liệu
  static int? _parseIntOrString(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idDanhmuc': idDanhmuc,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'cost': cost,
      'numberOfStudents': numberOfStudents,
      'totalLessons': totalLessons,
      'averageRating': averageRating,
      'author': author,
      'courseOutput': courseOutput,
      'description': description,
      'duration': duration,
      'language': language,
      'status': status,
      'type': type,
      'oldPrice': oldPrice,
      'categoryName': categoryName,
      'discountPercent': discountPercent,
      'isCombo': isCombo,
      'categoryId': categoryId,
    };
  }

  // Calculate the real discount percentage based on original price and current price
  int getRealDiscountPercent() {
    if (cost <= 0 || price >= cost) return discountPercent;

    // Calculate based on price difference
    final calculatedDiscount = ((cost - price) / cost * 100).round();

    // Return the larger of the two: explicit discount or calculated discount
    return calculatedDiscount > discountPercent
        ? calculatedDiscount
        : discountPercent;
  }
}
