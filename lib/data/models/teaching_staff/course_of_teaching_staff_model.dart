// Model đại diện cho khóa học mà giảng viên đang giảng dạy
// Được sử dụng để hiển thị thông tin khóa học trong danh sách khóa học của giảng viên
class CourseOfTeachingStaffModel {
  final int id;
  final String title;
  final String imageUrl;
  final int duration;
  final String courseOutput;
  final String language;
  final String type;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedDate;
  final bool deleted;
  final String author;
  final String categoryName;
  final String accountId;
  final String courseCategoryId;
  final int lessonCount;
  final int studentCount;
  final int itemCountReview;
  final double rating;
  final double cost;
  final double price;
  final int percentDiscount;
  final String level;
  final bool purchased;

  CourseOfTeachingStaffModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.courseOutput,
    required this.language,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedDate,
    required this.deleted,
    required this.author,
    required this.categoryName,
    required this.accountId,
    required this.courseCategoryId,
    required this.lessonCount,
    required this.studentCount,
    required this.itemCountReview,
    required this.rating,
    required this.cost,
    required this.price,
    required this.percentDiscount,
    required this.level,
    required this.purchased,
  });

  factory CourseOfTeachingStaffModel.fromJson(Map<String, dynamic> json) {
    return CourseOfTeachingStaffModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      duration: json['duration'] ?? 0,
      courseOutput: json['courseOutput'] ?? '',
      language: json['language'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'])
          : null,
      deleted: json['deleted'] ?? false,
      author: json['author'] ?? '',
      categoryName: json['categoryName'] ?? '',
      accountId: json['accountId'] ?? '',
      courseCategoryId: json['courseCategoryId'] ?? '',
      lessonCount: json['lessonCount'] ?? 0,
      studentCount: json['studentCount'] ?? 0,
      itemCountReview: json['itemCountReview'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      cost: (json['cost'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      percentDiscount: json['percentDiscount'] ?? 0,
      level: json['level'] ?? '',
      purchased: json['purchased'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'duration': duration,
      'courseOutput': courseOutput,
      'language': language,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedDate': deletedDate?.toIso8601String(),
      'deleted': deleted,
      'author': author,
      'categoryName': categoryName,
      'accountId': accountId,
      'courseCategoryId': courseCategoryId,
      'lessonCount': lessonCount,
      'studentCount': studentCount,
      'itemCountReview': itemCountReview,
      'rating': rating,
      'cost': cost,
      'price': price,
      'percentDiscount': percentDiscount,
      'level': level,
      'purchased': purchased,
    };
  }

  // Tạo bản sao với một số thuộc tính được thay đổi
  CourseOfTeachingStaffModel copyWith({
    int? id,
    String? title,
    String? imageUrl,
    int? duration,
    String? courseOutput,
    String? language,
    String? type,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedDate,
    bool? deleted,
    String? author,
    String? categoryName,
    String? accountId,
    String? courseCategoryId,
    int? lessonCount,
    int? studentCount,
    int? itemCountReview,
    double? rating,
    double? cost,
    double? price,
    int? percentDiscount,
    String? level,
    bool? purchased,
  }) {
    return CourseOfTeachingStaffModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      courseOutput: courseOutput ?? this.courseOutput,
      language: language ?? this.language,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedDate: deletedDate ?? this.deletedDate,
      deleted: deleted ?? this.deleted,
      author: author ?? this.author,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      courseCategoryId: courseCategoryId ?? this.courseCategoryId,
      lessonCount: lessonCount ?? this.lessonCount,
      studentCount: studentCount ?? this.studentCount,
      itemCountReview: itemCountReview ?? this.itemCountReview,
      rating: rating ?? this.rating,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      percentDiscount: percentDiscount ?? this.percentDiscount,
      level: level ?? this.level,
      purchased: purchased ?? this.purchased,
    );
  }
}
