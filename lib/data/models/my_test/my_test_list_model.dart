/// Lớp đại diện cho phản hồi API từ server
class MyTestResponse {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Dữ liệu phân trang đề thi
  final MyTestPaginatedData data;

  MyTestResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo MyTestResponse từ JSON
  factory MyTestResponse.fromJson(Map<String, dynamic> json) {
    return MyTestResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: MyTestPaginatedData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Chuyển đổi MyTestResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

/// Model biểu diễn một đề thi
class MyTestItem {
  final int testId;
  final String testTitle;
  final String testDescription;
  final DateTime testCreatedAt;
  final String imageUrl;

  MyTestItem({
    required this.testId,
    required this.testTitle,
    required this.testDescription,
    required this.testCreatedAt,
    required this.imageUrl,
  });

  factory MyTestItem.fromJson(Map<String, dynamic> json) {
    return MyTestItem(
      testId: json['testId'] as int,
      testTitle: json['testTitle'] as String,
      testDescription: json['testDescription'] as String,
      testCreatedAt: DateTime.parse(json['testCreatedAt'] as String),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testTitle': testTitle,
      'testDescription': testDescription,
      'testCreatedAt': testCreatedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

/// Model biểu diễn thông tin phân trang
class PageInfo {
  final int pageNumber;
  final int pageSize;
  final bool sorted;
  final bool empty;
  final bool unsorted;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sorted,
    required this.empty,
    required this.unsorted,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    final sort = json['sort'] as Map<String, dynamic>? ?? {};
    
    return PageInfo(
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
      sorted: sort['sorted'] as bool? ?? false,
      empty: sort['empty'] as bool? ?? true,
      unsorted: sort['unsorted'] as bool? ?? true,
      offset: json['offset'] as int? ?? 0,
      paged: json['paged'] as bool? ?? true,
      unpaged: json['unpaged'] as bool? ?? false,
    );
  }
}

/// Model biểu diễn dữ liệu phân trang danh sách đề thi
class MyTestPaginatedData {
  final int totalElements;
  final int totalPages;
  final PageInfo pageable;
  final int size;
  final List<MyTestItem> content;
  final int number;
  final bool sorted;
  final bool empty;
  final bool unsorted;
  final int numberOfElements;
  final bool first;
  final bool last;

  MyTestPaginatedData({
    required this.totalElements,
    required this.totalPages,
    required this.pageable,
    required this.size,
    required this.content,
    required this.number,
    required this.sorted,
    required this.empty,
    required this.unsorted,
    required this.numberOfElements,
    required this.first,
    required this.last,
  });

  factory MyTestPaginatedData.fromJson(Map<String, dynamic> json) {
    final sort = json['sort'] as Map<String, dynamic>? ?? {};
    final contentList = json['content'] as List<dynamic>? ?? [];
    
    return MyTestPaginatedData(
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      pageable: PageInfo.fromJson(json['pageable'] as Map<String, dynamic>? ?? {}),
      size: json['size'] as int? ?? 0,
      content: contentList
          .map((item) => MyTestItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      number: json['number'] as int? ?? 0,
      sorted: sort['sorted'] as bool? ?? false,
      empty: json['empty'] as bool? ?? true,
      unsorted: sort['unsorted'] as bool? ?? true,
      numberOfElements: json['numberOfElements'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
} 