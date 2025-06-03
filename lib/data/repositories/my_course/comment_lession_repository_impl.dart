// Implementation cho CommentLessonRepository

import 'package:tms_app/data/models/my_course/comment_lession_model.dart';
import 'package:tms_app/data/services/my_course/comment_lession_service.dart';
import 'package:tms_app/domain/repositories/my_course/comment_lession_repository.dart';

/// Lớp triển khai của CommentLessonRepository
class CommentLessonRepositoryImpl implements CommentLessonRepository {
  final CommentLessonService _commentLessonService;

  CommentLessonRepositoryImpl(
      {required CommentLessonService commentLessonService})
      : _commentLessonService = commentLessonService;

  @override
  Future<CommentLessonResponse> getComments({
    required int videoId,
    required int lessonId,
    required String targetType,
    int page = 0,
    int size = 20,
  }) async {
    return await _commentLessonService.getComments(
      videoId: videoId,
      lessonId: lessonId,
      targetType: targetType,
      page: page,
      size: size,
    );
  }
}
