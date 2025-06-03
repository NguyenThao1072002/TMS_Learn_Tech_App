import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/my_course/comment_lession_model.dart';
import 'package:tms_app/domain/usecases/my_course/comment_lession_usecase.dart';

/// Widget hiển thị phần bình luận của bài học
class CommentSectionWidget extends StatefulWidget {
  /// Callback khi người dùng gửi bình luận mới
  final Function(String) onCommentSubmit;

  /// ID của video bài học
  final int? videoId;

  /// ID của bài học
  final int? lessonId;

  const CommentSectionWidget({
    Key? key,
    required this.onCommentSubmit,
    this.videoId = 0,
    this.lessonId = 0,
  }) : super(key: key);

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final CommentLessonUseCase _commentLessonUseCase = sl<CommentLessonUseCase>();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<CommentModel> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Tải danh sách bình luận từ API
  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print(
          '🔍 Đang tải bình luận cho videoId=${widget.videoId}, lessonId=${widget.lessonId}');

      // Kiểm tra tham số đầu vào
      if (widget.videoId == 0 || widget.lessonId == 0) {
        setState(() {
          _errorMessage = 'Không thể tải bình luận: Thiếu thông tin bài học';
          _isLoading = false;
        });
        return;
      }

      final response = await _commentLessonUseCase.getComments(
        videoId: widget.videoId ?? 0,
        lessonId: widget.lessonId ?? 0,
        targetType: 'COURSE',
      );

      setState(() {
        _comments = response.content;
        _isLoading = false;
      });

      print('✅ Đã tải ${_comments.length} bình luận');
    } catch (e) {
      print('❌ Lỗi khi tải bình luận: $e');
      setState(() {
        _errorMessage = 'Không thể tải bình luận: $e';
        _isLoading = false;
      });
    }
  }

  /// Gửi bình luận mới
  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Chỉ gọi callback để thông báo có bình luận mới
      widget.onCommentSubmit(comment);

      // Xóa nội dung đã nhập
      _commentController.clear();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chức năng gửi bình luận sẽ được cập nhật sau'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi bình luận: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phần bình luận
          const Row(
            children: [
              Icon(Icons.forum, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Bình luận và thảo luận',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ô nhập bình luận mới
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Avatar người dùng
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 12),

                // Ô nhập bình luận
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Viết bình luận của bạn...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    maxLines: 1,
                  ),
                ),

                // Nút gửi
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hiển thị số lượng bình luận
          Row(
            children: [
              Text(
                '${_comments.length} bình luận',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Nút tải lại bình luận
              if (!_isLoading)
                InkWell(
                  onTap: _loadComments,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'Tải lại',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Hiển thị trạng thái tải
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          // Hiển thị thông báo lỗi
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.orange),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadComments,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Hiển thị danh sách bình luận
          else if (_comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có bình luận nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hãy là người đầu tiên bình luận!',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return CommentItemWidget(comment: comment);
              },
            ),
        ],
      ),
    );
  }
}

/// Widget hiển thị một bình luận
class CommentItemWidget extends StatelessWidget {
  final CommentModel comment;

  const CommentItemWidget({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentLessonUseCase = sl<CommentLessonUseCase>();
    final formattedTime =
        commentLessonUseCase.formatCommentTime(comment.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    comment.image != null ? NetworkImage(comment.image!) : null,
                backgroundColor: Colors.grey[300],
                child: comment.image == null
                    ? Text(
                        comment.fullname[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
              ),
              const SizedBox(width: 8),

              // Tên người dùng và thời gian
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nội dung bình luận
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),

          const SizedBox(height: 8),

          // Các nút tương tác
          Row(
            children: [
              // Nút thích
              InkWell(
                onTap: () {
                  // Hiển thị thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Chức năng thích bình luận sẽ được cập nhật sau'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      comment.liked != null
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: comment.liked != null
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.liked != null ? '${comment.liked}' : 'Thích',
                      style: TextStyle(
                        fontSize: 12,
                        color: comment.liked != null
                            ? Colors.blue
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Nút trả lời
              InkWell(
                onTap: () {
                  // Hiển thị thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Chức năng trả lời bình luận sẽ được cập nhật sau'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.reply_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Trả lời',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Hiển thị các phản hồi nếu có
          if (comment.replies != null && comment.replies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  Text(
                    '${comment.replies!.length} phản hồi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...comment.replies!
                      .map((reply) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildReplyItem(
                                context, reply, commentLessonUseCase),
                          ))
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Xây dựng widget hiển thị phản hồi cho một bình luận
  Widget _buildReplyItem(
    BuildContext context,
    CommentModel reply,
    CommentLessonUseCase commentLessonUseCase,
  ) {
    final formattedTime =
        commentLessonUseCase.formatCommentTime(reply.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 14,
          backgroundImage:
              reply.image != null ? NetworkImage(reply.image!) : null,
          backgroundColor: Colors.grey[300],
          child: reply.image == null
              ? Text(
                  reply.fullname[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              : null,
        ),
        const SizedBox(width: 8),

        // Nội dung phản hồi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    reply.fullname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reply.content,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      // Xử lý thích phản hồi
                    },
                    child: Row(
                      children: [
                        Icon(
                          reply.liked != null
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          size: 14,
                          color: reply.liked != null
                              ? Colors.blue
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reply.liked != null ? '${reply.liked}' : 'Thích',
                          style: TextStyle(
                            fontSize: 11,
                            color: reply.liked != null
                                ? Colors.blue
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
