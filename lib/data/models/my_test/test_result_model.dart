/// Lớp đại diện cho phản hồi API kết quả đề thi
class TestResultResponse {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Dữ liệu phân trang kết quả đề thi
  final TestResultPaginatedData data;

  TestResultResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo TestResultResponse từ JSON
  factory TestResultResponse.fromJson(Map<String, dynamic> json) {
    return TestResultResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: TestResultPaginatedData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Chuyển đổi TestResultResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Model biểu diễn một kết quả đề thi
class TestResultItem {
  /// ID của kết quả bài thi
  final int testResultId;
  
  /// ID của đề thi
  final int testId;
  
  /// Tiêu đề của đề thi
  final String testTitle;
  
  /// Điểm cao nhất đạt được
  final double maxScore;
  
  /// Thời gian tạo kết quả
  final DateTime createdAt;
  
  /// Phần trăm hoàn thành
  final double completedPercentage;

  TestResultItem({
    required this.testResultId,
    required this.testId,
    required this.testTitle,
    required this.maxScore,
    required this.createdAt,
    required this.completedPercentage,
  });

  factory TestResultItem.fromJson(Map<String, dynamic> json) {
    return TestResultItem(
      testResultId: json['testResultId'] as int,
      testId: json['testId'] as int,
      testTitle: json['testTitle'] as String,
      maxScore: (json['maxScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedPercentage: (json['completedPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testResultId': testResultId,
      'testId': testId,
      'testTitle': testTitle,
      'maxScore': maxScore,
      'createdAt': createdAt.toIso8601String(),
      'completedPercentage': completedPercentage,
    };
  }
}

/// Model biểu diễn thông tin phân trang cho kết quả đề thi
class TestResultPageInfo {
  final int pageNumber;
  final int pageSize;
  final bool sorted;
  final bool empty;
  final bool unsorted;
  final int offset;
  final bool paged;
  final bool unpaged;

  TestResultPageInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sorted,
    required this.empty,
    required this.unsorted,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory TestResultPageInfo.fromJson(Map<String, dynamic> json) {
    final sort = json['sort'] as Map<String, dynamic>? ?? {};
    
    return TestResultPageInfo(
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

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sort': {
        'sorted': sorted,
        'empty': empty,
        'unsorted': unsorted,
      },
      'offset': offset,
      'paged': paged,
      'unpaged': unpaged,
    };
  }
}

/// Model biểu diễn dữ liệu phân trang danh sách kết quả đề thi
class TestResultPaginatedData {
  final int totalElements;
  final int totalPages;
  final TestResultPageInfo pageable;
  final int size;
  final List<TestResultItem> content;
  final int number;
  final bool sorted;
  final bool empty;
  final bool unsorted;
  final int numberOfElements;
  final bool first;
  final bool last;

  TestResultPaginatedData({
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

  factory TestResultPaginatedData.fromJson(Map<String, dynamic> json) {
    final sort = json['sort'] as Map<String, dynamic>? ?? {};
    final contentList = json['content'] as List<dynamic>? ?? [];
    
    return TestResultPaginatedData(
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      pageable: TestResultPageInfo.fromJson(json['pageable'] as Map<String, dynamic>? ?? {}),
      size: json['size'] as int? ?? 0,
      content: contentList
          .map((item) => TestResultItem.fromJson(item as Map<String, dynamic>))
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

  Map<String, dynamic> toJson() {
    return {
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageable': pageable.toJson(),
      'size': size,
      'content': content.map((item) => item.toJson()).toList(),
      'number': number,
      'sort': {
        'sorted': sorted,
        'empty': empty,
        'unsorted': unsorted,
      },
      'numberOfElements': numberOfElements,
      'first': first,
      'last': last,
      'empty': empty,
    };
  }
} 