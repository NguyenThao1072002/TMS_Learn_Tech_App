import 'package:equatable/equatable.dart';

/// Model for like/dislike comment API response
class LikeCommentResponse extends Equatable {
  final int status;
  final String message;
  final dynamic data;

  const LikeCommentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LikeCommentResponse.fromJson(Map<String, dynamic> json) {
    return LikeCommentResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }

  /// Check if the response indicates a successful like action
  bool get isLiked => status == 200 && message.contains('like');

  /// Check if the response indicates a successful unlike action
  bool get isUnliked => status == 200 && message.contains('dislike');

  /// Check if the response indicates any successful action
  bool get isSuccess => status == 200;

  @override
  List<Object?> get props => [status, message, data];
}

/// Model for like/dislike comment request
class LikeCommentRequest {
  final int commentId;
  final int accountId;

  const LikeCommentRequest({
    required this.commentId,
    required this.accountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'accountId': accountId,
    };
  }

  /// Convert request parameters to query string
  String toQueryString() {
    return 'accountId=$accountId';
  }
}
