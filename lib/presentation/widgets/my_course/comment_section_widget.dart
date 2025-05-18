import 'package:flutter/material.dart';

class CommentSectionWidget extends StatefulWidget {
  final Function(String) onCommentSubmit;

  const CommentSectionWidget({
    Key? key,
    required this.onCommentSubmit,
  }) : super(key: key);

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _sampleComments = [
    Comment(
      username: 'Nguyễn Văn A',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      timeAgo: '2 giờ trước',
      content: 'Bài học rất hữu ích, tôi đã học được nhiều kiến thức mới.',
      likes: 12,
    ),
    Comment(
      username: 'Trần Thị B',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      timeAgo: '1 ngày trước',
      content:
          'Giảng viên trình bày rất rõ ràng, dễ hiểu. Cảm ơn vì bài giảng chất lượng!',
      likes: 8,
    ),
    Comment(
      username: 'Lê Văn C',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      timeAgo: '3 ngày trước',
      content:
          'Tôi có thắc mắc về phần X trong bài giảng, liệu có thể giải thích rõ hơn được không?',
      likes: 3,
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thảo luận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Comment input field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=7'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Viết bình luận...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      widget.onCommentSubmit(_commentController.text);
                      _commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Comment list
          for (final comment in _sampleComments)
            CommentItemWidget(comment: comment),

          const SizedBox(height: 16),

          // View more comments button
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.comment, size: 16),
              label: const Text('Xem thêm bình luận'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItemWidget extends StatelessWidget {
  final Comment comment;

  const CommentItemWidget({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
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
                backgroundImage: NetworkImage(comment.avatarUrl),
                onBackgroundImageError: (exception, stackTrace) =>
                    const Icon(Icons.person),
              ),
              const SizedBox(width: 8),
              // Username and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      comment.timeAgo,
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
          // Comment content
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 8),
          // Actions
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${comment.likes}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.reply_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Trả lời',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Comment {
  final String username;
  final String avatarUrl;
  final String timeAgo;
  final String content;
  final int likes;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.timeAgo,
    required this.content,
    required this.likes,
  });
}
