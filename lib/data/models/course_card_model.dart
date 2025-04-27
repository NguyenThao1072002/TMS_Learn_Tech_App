class CourseCardModel {
  final int id;
  final int idDanhmuc;
  final String title;
  final String imageUrl;
  final double price;
  final double cost;
  final int numberOfStudents;
  final int totalLessons;
  final double averageRating;
  final String author;
  final String courseOutput;
  final String description;
  final int duration;
  final String language;
  final bool status;
  final String type;
  final String? oldPrice;
  final String categoryName;
  int discountPercent; // Tính toán phần trăm giảm giá

  CourseCardModel({
    required this.id,
    required this.idDanhmuc,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.cost,
    required this.numberOfStudents,
    required this.totalLessons,
    required this.averageRating,
    required this.author,
    required this.courseOutput,
    required this.description,
    required this.duration,
    required this.language,
    required this.status,
    required this.type,
    this.oldPrice,
    required this.categoryName,
    this.discountPercent = 0, // Tính toán phần trăm giảm giá nếu có
  });

  // Getter cho oldPrice để chuyển đổi từ String? sang double?
  double? get oldPriceAsDouble {
    if (oldPrice == null) return null;
    return double.tryParse(
        oldPrice!); // Chuyển String sang double, nếu không hợp lệ trả về null
  }

  // Phương thức từ JSON
  factory CourseCardModel.fromJson(Map<String, dynamic> json) {
    return CourseCardModel(
      id: json['id'],
      idDanhmuc: json['idDanhmuc'],
      title: json['title'] ?? '', // Default empty string if null
      imageUrl: json['imageUrl'] ?? '', // Default empty string if null
      price: json['price']?.toDouble() ?? 0.0,
      cost: json['cost']?.toDouble() ?? 0.0,
      numberOfStudents: json['numberOfStudents'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      author: json['author'] ?? '',
      courseOutput: json['courseOutput'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      language: json['language'] ?? '',
      status: json['status'] ?? false,
      type: json['type'] ?? '',
      oldPrice: json['oldPrice'] as String?,
      categoryName: json['categoryName'] ?? '',
      discountPercent: json['discountPercent'] ?? 0,
    );
  }

  // Phương thức chuyển sang JSON
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
      'discountPercent': discountPercent, // Added discountPercent
    };
  }
}
