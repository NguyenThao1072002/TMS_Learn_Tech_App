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
  });

  double? get oldPriceAsDouble {
    if (oldPrice == null) return null;
    return double.tryParse(oldPrice!);
  }

  factory CourseCardModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Đang parse CourseCardModel: ${json.keys.toList()}');

      // Xử lý các tên trường có thể thay đổi hoặc thiếu
      final id = json['id'] ?? 0;
      final title = json['title'] ?? json['name'] ?? '';
      final imageUrl =
          json['imageUrl'] ?? json['image'] ?? json['thumbnail'] ?? '';

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
      );
    } catch (e) {
      print('❌ Lỗi khi parse CourseCardModel: $e');
      print('💡 JSON data: $json');

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
    };
  }
}
