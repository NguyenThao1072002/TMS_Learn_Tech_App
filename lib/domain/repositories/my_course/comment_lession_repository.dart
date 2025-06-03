// Interface repository cho bình luận bài học

import 'package:tms_app/data/models/my_course/comment_lession_model.dart';

/// Repository interface định nghĩa các phương thức làm việc với bình luận bài học
abstract class CommentLessonRepository {
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
  });
}
