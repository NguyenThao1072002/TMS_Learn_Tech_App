// UseCase cho bình luận bài học

import 'package:tms_app/data/models/my_course/comment_lession_model.dart';
import 'package:tms_app/data/models/my_course/like_comment_model.dart';
import 'package:tms_app/domain/repositories/my_course/comment_lession_repository.dart';

/// UseCase xử lý các tác vụ liên quan đến bình luận bài học
class CommentLessonUseCase {
  final CommentLessonRepository _commentLessonRepository;

  CommentLessonUseCase(this._commentLessonRepository);

  /// Lấy danh sách bình luận của bài học
  ///
  /// [videoId] ID của video bài học
  /// [lessonId] ID của bài học
  /// [targetType] Loại đối tượng được bình luận (COURSE, LESSON, VIDEO)
  /// [page] Số trang (mặc định là 0)
  /// [size] Số lượng bình luận mỗi trang (mặc định là 20)
  Future<CommentLessonResponse> getComments({
    required int videoId,
    required int lessonId,
    required String targetType,
    int page = 0,
    int size = 20,
  }) async {
    return await _commentLessonRepository.getComments(
      videoId: videoId,
      lessonId: lessonId,
      targetType: targetType,
      page: page,
      size: size,
    );
  }

  /// Like hoặc dislike một bình luận
  ///
  /// [commentId] ID của bình luận
  /// [accountId] ID của tài khoản người dùng
  /// Return: LikeCommentResponse chứa thông tin về trạng thái like/dislike
  Future<LikeCommentResponse> likeComment({
    required int commentId,
    required int accountId,
  }) async {
    return await _commentLessonRepository.likeComment(
      commentId: commentId,
      accountId: accountId,
    );
  }

  /// Kiểm tra bình luận đã được like hay chưa
  ///
  /// [liked] Giá trị liked từ CommentModel
  /// Return: true nếu bình luận đã được like, false nếu chưa
  bool isCommentLiked(int? liked) {
    return liked != null && liked > 0;
  }

  /// Định dạng thời gian hiển thị cho bình luận
  ///
  /// [createdAt] Thời gian tạo bình luận dạng ISO 8601
  /// Trả về chuỗi thời gian đã định dạng (VD: "vừa xong", "5 phút trước", "2 giờ trước", "hôm qua", "25/04/2025")
  String formatCommentTime(String createdAt) {
    try {
      final DateTime commentTime = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(commentTime);

      if (difference.inSeconds < 60) {
        return 'vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 2) {
        return 'hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        // Định dạng ngày/tháng/năm
        return '${commentTime.day.toString().padLeft(2, '0')}/${commentTime.month.toString().padLeft(2, '0')}/${commentTime.year}';
      }
    } catch (e) {
      return createdAt; // Trả về chuỗi gốc nếu có lỗi
    }
  }
}
