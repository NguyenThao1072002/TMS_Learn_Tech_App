class ReviewCourseModel {
  final int id;
  final int rating;
  final String? review;
  final String updatedAt;
  final String createdAt;
  final int accountId;
  final int courseId;
  final String fullname;
  final String image;

  ReviewCourseModel({
    required this.id,
    required this.rating,
    this.review,
    required this.updatedAt,
    required this.createdAt,
    required this.accountId,
    required this.courseId,
    required this.fullname,
    required this.image,
  });

  factory ReviewCourseModel.fromJson(Map<String, dynamic> json) {
    return ReviewCourseModel(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      accountId: json['account_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      fullname: json['fullname'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review': review,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'account_id': accountId,
      'course_id': courseId,
      'fullname': fullname,
      'image': image,
    };
  }
}

class ReviewPaginationResponse {
  final int totalElements;
  final int totalPages;
  final List<ReviewCourseModel> content;
  final PageInfo pageable;
  final int number;
  final int size;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  ReviewPaginationResponse({
    required this.totalElements,
    required this.totalPages,
    required this.content,
    required this.pageable,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory ReviewPaginationResponse.fromJson(Map<String, dynamic> json) {
    return ReviewPaginationResponse(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      content: json['content'] != null
          ? List<ReviewCourseModel>.from(
              json['content'].map((x) => ReviewCourseModel.fromJson(x)))
          : [],
      pageable: json['pageable'] != null
          ? PageInfo.fromJson(json['pageable'])
          : PageInfo.empty(),
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}

class PageInfo {
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      offset: json['offset'] ?? 0,
      paged: json['paged'] ?? false,
      unpaged: json['unpaged'] ?? false,
    );
  }

  factory PageInfo.empty() {
    return PageInfo(
      pageNumber: 0,
      pageSize: 0,
      offset: 0,
      paged: false,
      unpaged: false,
    );
  }
}
