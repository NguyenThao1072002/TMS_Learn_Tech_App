import 'dart:convert';

class MyCourseListResponse {
  final int totalElements;
  final int totalPages;
  final PageableInfo pageable;
  final int size;
  final List<MyCourseItem> content;
  final int number;
  final SortInfo sort;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  MyCourseListResponse({
    required this.totalElements,
    required this.totalPages,
    required this.pageable,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory MyCourseListResponse.fromJson(Map<String, dynamic> json) {
    return MyCourseListResponse(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      pageable: PageableInfo.fromJson(json['pageable'] ?? {}),
      size: json['size'] ?? 0,
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => MyCourseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      number: json['number'] ?? 0,
      sort: SortInfo.fromJson(json['sort'] ?? {}),
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }

  static MyCourseListResponse parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return MyCourseListResponse.fromJson(parsed);
  }
}

class PageableInfo {
  final int pageNumber;
  final int pageSize;
  final SortInfo sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageableInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageableInfo.fromJson(Map<String, dynamic> json) {
    return PageableInfo(
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      sort: SortInfo.fromJson(json['sort'] ?? {}),
      offset: json['offset'] ?? 0,
      paged: json['paged'] ?? true,
      unpaged: json['unpaged'] ?? false,
    );
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
    return SortInfo(
      sorted: json['sorted'] ?? true,
      empty: json['empty'] ?? false,
      unsorted: json['unsorted'] ?? false,
    );
  }
}

class MyCourseItem {
  final int id;
  final String title;
  final String imageUrl;
  final int duration;
  final String type; // FREE, FEE
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deletedDate;
  final String author;
  final double progress;
  final String? statusCompleted; // Actived, Studying, Completed

  // Additional fields for completed courses
  final String? certificateUrl;
  final DateTime? completedDate;

  MyCourseItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedDate,
    required this.author,
    required this.progress,
    this.statusCompleted,
    this.certificateUrl,
    this.completedDate,
  });

  factory MyCourseItem.fromJson(Map<String, dynamic> json) {
    // Parse progress value
    double progressValue = 0.0;
    if (json['progress'] != null) {
      String rawProgress = json['progress'].toString();
      progressValue = double.tryParse(rawProgress) ?? 0.0;
      print(
          '📊 Raw progress value from API: "$rawProgress", parsed as: $progressValue');

      // If progress is greater than 1, assume it's a percentage and convert to a fraction
      if (progressValue > 1.0) {
        double originalValue = progressValue;
        progressValue = progressValue / 100.0;
        print(
            '📊 Converting progress from $originalValue% to fraction: $progressValue');
      }
    }

    return MyCourseItem(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      duration: json['duration'] is String
          ? int.tryParse(json['duration']) ?? 0
          : json['duration'] ?? 0,
      type: json['type'] ?? 'FREE',
      status: json['status'] ?? true,
      statusCompleted: json['statusCompleted'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'])
          : DateTime.now(),
      author: json['author'] ?? '',
      progress: progressValue,
      certificateUrl: json['certificateUrl'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }
}
