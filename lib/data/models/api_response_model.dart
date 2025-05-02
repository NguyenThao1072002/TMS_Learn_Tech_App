class ApiResponse<T> {
  final int status;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    try {
      print('🔍 Parsing ApiResponse: ${json.keys.toList()}');
      return ApiResponse(
        status: json['status'],
        message: json['message'],
        data: fromJsonT(json['data']),
      );
    } catch (e) {
      print('❌ Error parsing ApiResponse: $e');
      rethrow; // Re-throw to handle in the service
    }
  }
}

class PagedResponse<T> {
  final int totalElements;
  final int totalPages;
  final PageInfo pageable;
  final int size;
  final List<T> content;
  final int number;
  final SortInfo sort;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  PagedResponse({
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

  factory PagedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    try {
      print('🔍 Parsing PagedResponse: ${json.keys.toList()}');

      final contentList = json['content'] as List;
      print('📋 Content list length: ${contentList.length}');

      if (contentList.isNotEmpty) {
        print(
            '📄 Sample content item keys: ${(contentList.first as Map<String, dynamic>).keys.toList()}');
      }

      return PagedResponse(
        totalElements: json['totalElements'],
        totalPages: json['totalPages'],
        pageable: PageInfo.fromJson(json['pageable']),
        size: json['size'],
        content: contentList
            .map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList(),
        number: json['number'],
        sort: SortInfo.fromJson(json['sort']),
        numberOfElements: json['numberOfElements'],
        first: json['first'],
        last: json['last'],
        empty: json['empty'],
      );
    } catch (e) {
      print('❌ Error parsing PagedResponse: $e');
      rethrow; // Re-throw to handle in the service
    }
  }
}

class PageInfo {
  final int pageNumber;
  final int pageSize;
  final SortInfo sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    try {
      return PageInfo(
        pageNumber: json['pageNumber'],
        pageSize: json['pageSize'],
        sort: SortInfo.fromJson(json['sort']),
        offset: json['offset'],
        paged: json['paged'],
        unpaged: json['unpaged'],
      );
    } catch (e) {
      print('❌ Error parsing PageInfo: $e');
      rethrow;
    }
  }
}

class SortInfo {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  SortInfo({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory SortInfo.fromJson(Map<String, dynamic> json) {
    try {
      return SortInfo(
        sorted: json['sorted'],
        empty: json['empty'],
        unsorted: json['unsorted'],
      );
    } catch (e) {
      print('❌ Error parsing SortInfo: $e');
      rethrow;
    }
  }
}
