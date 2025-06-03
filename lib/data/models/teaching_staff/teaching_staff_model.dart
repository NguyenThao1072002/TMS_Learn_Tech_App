class TeachingStaffResponse {
  final int status;
  final String message;
  final TeachingStaffData data;

  TeachingStaffResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TeachingStaffResponse.fromJson(Map<String, dynamic> json) {
    return TeachingStaffResponse(
      status: json['status'] ?? 200,
      message: json['message'] ?? 'Lấy danh sách giảng viên thành công',
      data: TeachingStaffData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TeachingStaffData {
  final int totalElements;
  final int totalPages;
  final Pageable pageable;
  final int size;
  final List<TeachingStaff> content;
  final int number;
  final Sort sort;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  TeachingStaffData({
    required this.totalElements,
    required this.totalPages,
    required this.pageable,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory TeachingStaffData.fromJson(Map<String, dynamic> json) {
    return TeachingStaffData(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      pageable: Pageable.fromJson(json['pageable'] ?? {}),
      size: json['size'] ?? 0,
      content: (json['content'] as List<dynamic>?)
              ?.map((x) => TeachingStaff.fromJson(x))
              .toList() ??
          [],
      number: json['number'] ?? 0,
      sort: Sort.fromJson(json['sort'] ?? {}),
      numberOfElements: json['numberOfElements'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageable': pageable.toJson(),
      'size': size,
      'content': content.map((x) => x.toJson()).toList(),
      'number': number,
      'sort': sort.toJson(),
      'numberOfElements': numberOfElements,
      'first': first,
      'last': last,
      'empty': empty,
    };
  }
}

class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      sort: Sort.fromJson(json['sort'] ?? {}),
      offset: json['offset'] ?? 0,
      paged: json['paged'] ?? true,
      unpaged: json['unpaged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sort': sort.toJson(),
      'offset': offset,
      'paged': paged,
      'unpaged': unpaged,
    };
  }
}

class Sort {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  Sort({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json['sorted'] ?? false,
      empty: json['empty'] ?? true,
      unsorted: json['unsorted'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sorted': sorted,
      'empty': empty,
      'unsorted': unsorted,
    };
  }
}

class TeachingStaff {
  final int id;
  final int accountId;
  final String fullname;
  final String avatarUrl;
  final int courseCount;
  final double averageRating;
  final String instruction;
  final String expert;
  final int totalStudents;
  final int categoryId;
  final String categoryName;

  TeachingStaff({
    required this.id,
    required this.accountId,
    required this.fullname,
    required this.avatarUrl,
    required this.courseCount,
    required this.averageRating,
    required this.instruction,
    required this.expert,
    required this.totalStudents,
    required this.categoryId,
    required this.categoryName,
  });

  factory TeachingStaff.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý URL ảnh
      String avatarUrl = json['avatarUrl'] ?? '';
      if (avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http') &&
          !avatarUrl.startsWith('assets/')) {
        avatarUrl = 'http://103.166.143.198:8080' +
            (avatarUrl.startsWith('/') ? '' : '/') +
            avatarUrl;
      }

      // Xử lý averageRating
      final rating = json['averageRating'] ?? 0.0;
      final averageRating = rating is double ? rating : rating.toDouble();

      return TeachingStaff(
        id: json['id'] ?? 0,
        accountId: json['accountId'] ?? 0,
        fullname: json['fullname'] ?? '',
        avatarUrl: avatarUrl,
        courseCount: json['courseCount'] ?? 0,
        averageRating: averageRating,
        instruction: json['instruction'] ?? '',
        expert: json['expert'] ?? '',
        totalStudents: json['totalStudents'] ?? 0,
        categoryId: json['categoryId'] ?? 0,
        categoryName: json['categoryName'] ?? '',
      );
    } catch (e) {
      // Trả về đối tượng mặc định an toàn khi có lỗi
      return TeachingStaff(
        id: 0,
        accountId: 0,
        fullname: 'Lỗi tải thông tin giảng viên',
        avatarUrl: '',
        courseCount: 0,
        averageRating: 0.0,
        instruction: '',
        expert: '',
        totalStudents: 0,
        categoryId: 0,
        categoryName: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'fullname': fullname,
      'avatarUrl': avatarUrl,
      'courseCount': courseCount,
      'averageRating': averageRating,
      'instruction': instruction,
      'expert': expert,
      'totalStudents': totalStudents,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

  // Tạo bản sao với một số thuộc tính được thay đổi
  TeachingStaff copyWith({
    int? id,
    int? accountId,
    String? fullname,
    String? avatarUrl,
    int? courseCount,
    double? averageRating,
    String? instruction,
    String? expert,
    int? totalStudents,
    int? categoryId,
    String? categoryName,
  }) {
    return TeachingStaff(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      fullname: fullname ?? this.fullname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      courseCount: courseCount ?? this.courseCount,
      averageRating: averageRating ?? this.averageRating,
      instruction: instruction ?? this.instruction,
      expert: expert ?? this.expert,
      totalStudents: totalStudents ?? this.totalStudents,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
