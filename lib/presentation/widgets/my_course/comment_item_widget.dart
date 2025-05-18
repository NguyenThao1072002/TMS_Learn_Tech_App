import 'package:flutter/material.dart';

class CommentItemWidget extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String content;
  final String avatarUrl;
  final int likes;

  const CommentItemWidget({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.avatarUrl,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: NetworkImage(avatarUrl),
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
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
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
            content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 8),
          // Actions
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$likes',
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

class CommentSectionWidget extends StatelessWidget {
  final Function(String) onCommentSubmit;

  const CommentSectionWidget({
    super.key,
    required this.onCommentSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bình luận',
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
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Viết bình luận của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: () {
                    // Get text from controller and pass to callback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi bình luận'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    onCommentSubmit('Comment text');
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sample comments
          const CommentItemWidget(
            username: 'Nguyễn Văn A',
            timeAgo: '2 ngày trước',
            content:
                'Bài học rất hay và dễ hiểu. Cảm ơn giảng viên đã chia sẻ!',
            avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
            likes: 5,
          ),
          const SizedBox(height: 16),
          const CommentItemWidget(
            username: 'Trần Thị B',
            timeAgo: '1 tuần trước',
            content:
                'Tôi có thắc mắc về phần triển khai API, liệu có thể giải thích rõ hơn được không?',
            avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
            likes: 3,
          ),
          const SizedBox(height: 16),
          const CommentItemWidget(
            username: 'Lê Văn C',
            timeAgo: '2 tuần trước',
            content:
                'Kiến thức trong bài học này có thể áp dụng cho các dự án thực tế không? Tôi đang làm một ứng dụng tương tự.',
            avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
            likes: 8,
          ),
        ],
      ),
    );
  }
}
