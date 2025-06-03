// Model cho API bình luận bài học
// API: {{api}}/api/comments/course?videoId=6&targetType=COURSE&lessonId=6

import 'package:equatable/equatable.dart';

/// Mô hình dữ liệu cho danh sách bình luận bài học
class CommentLessonResponse {
  final int totalElements;
  final int totalPages;
  final PageableInfo pageable;
  final int size;
  final List<CommentModel> content;
  final int number;
  final SortInfo sort;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  CommentLessonResponse({
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

  factory CommentLessonResponse.fromJson(Map<String, dynamic> json) {
    return CommentLessonResponse(
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      pageable: PageableInfo.fromJson(json['pageable'] as Map<String, dynamic>),
      size: json['size'] as int,
      content: (json['content'] as List<dynamic>)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      number: json['number'] as int,
      sort: SortInfo.fromJson(json['sort'] as Map<String, dynamic>),
      numberOfElements: json['numberOfElements'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
      empty: json['empty'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageable': pageable.toJson(),
      'size': size,
      'content': content.map((e) => e.toJson()).toList(),
      'number': number,
      'sort': sort.toJson(),
      'numberOfElements': numberOfElements,
      'first': first,
      'last': last,
      'empty': empty,
    };
  }
}

/// Mô hình dữ liệu cho thông tin phân trang
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
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      sort: SortInfo.fromJson(json['sort'] as Map<String, dynamic>),
      offset: json['offset'] as int,
      paged: json['paged'] as bool,
      unpaged: json['unpaged'] as bool,
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

/// Mô hình dữ liệu cho thông tin sắp xếp
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
      sorted: json['sorted'] as bool,
      empty: json['empty'] as bool,
      unsorted: json['unsorted'] as bool,
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

/// Mô hình dữ liệu cho bình luận
class CommentModel extends Equatable {
  final int commentId;
  final String content;
  final int accountId;
  final String fullname;
  final String? image;
  final int? liked;
  final String targetType;
  final String createdAt;
  final List<CommentModel>? replies;

  const CommentModel({
    required this.commentId,
    required this.content,
    required this.accountId,
    required this.fullname,
    this.image,
    this.liked,
    required this.targetType,
    required this.createdAt,
    this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] as int,
      content: json['content'] as String,
      accountId: json['accountId'] as int,
      fullname: json['fullname'] as String,
      image: json['image'] as String?,
      liked: json['liked'] as int?,
      targetType: json['targetType'] as String,
      createdAt: json['createdAt'] as String,
      replies: json['replies'] != null
          ? (json['replies'] as List<dynamic>)
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'content': content,
      'accountId': accountId,
      'fullname': fullname,
      'image': image,
      'liked': liked,
      'targetType': targetType,
      'createdAt': createdAt,
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        commentId,
        content,
        accountId,
        fullname,
        image,
        liked,
        targetType,
        createdAt,
        replies,
      ];
}
