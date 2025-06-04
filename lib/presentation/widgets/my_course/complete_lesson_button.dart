import 'package:flutter/material.dart';

class CompleteLessonButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback? onStartTest;
  final VoidCallback? onNextLesson;
  final bool hasTest;
  final String? errorMessage;

  const CompleteLessonButton({
    Key? key,
    required this.isCompleted,
    required this.onComplete,
    this.onStartTest,
    this.onNextLesson,
    this.hasTest = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<CompleteLessonButton> createState() => _CompleteLessonButtonState();
}

class _CompleteLessonButtonState extends State<CompleteLessonButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Debug log
    print(
        'CompleteLessonButton: isCompleted=${widget.isCompleted}, hasTest=${widget.hasTest}, onNextLesson=${widget.onNextLesson != null ? "available" : "null"}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị thông báo lỗi nếu có
            if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isCompleted ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isCompleted ? Icons.check : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isCompleted
                            ? 'Đã hoàn thành bài học'
                            : 'Chưa hoàn thành bài học',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!widget.isCompleted)
                        const Text(
                          'Hãy hoàn thành bài học để mở khóa bài tiếp theo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                // Phần này là nội dung nút phải
                _buildActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tách riêng phần xây dựng nút hành động bên phải
  Widget _buildActionButton() {
    // Trường hợp 1: Đã hoàn thành bài học
    if (widget.isCompleted) {
      // Nếu có bài kiểm tra, hiển thị nút làm bài kiểm tra
      if (widget.hasTest) {
        return ElevatedButton.icon(
          onPressed: () {
            print('🧪 Nhấn nút làm bài kiểm tra');
            if (widget.onStartTest != null) {
              widget.onStartTest!();
            }
          },
          icon: const Icon(Icons.quiz),
          label: const Text('Làm bài kiểm tra'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      }
      // Nếu không có bài kiểm tra và có thể chuyển tiếp, hiển thị nút bài tiếp theo
      else if (widget.onNextLesson != null) {
        return ElevatedButton.icon(
          onPressed: () {
            print('➡️ Nhấn nút bài học tiếp theo');
            print('➡️ Gọi callback onNextLesson được truyền từ parent widget');
            widget.onNextLesson!();
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Bài học tiếp theo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      }
    }
    // Trường hợp 2: Chưa hoàn thành bài học
    else {
      // Nếu có bài kiểm tra, hiển thị nút làm bài kiểm tra
      if (widget.hasTest) {
        return ElevatedButton.icon(
          onPressed: () {
            print('🧪 Nhấn nút làm bài kiểm tra (chưa hoàn thành)');
            if (widget.onStartTest != null) {
              widget.onStartTest!();
            }
          },
          icon: const Icon(Icons.quiz),
          label: const Text('Làm bài kiểm tra'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      }
      // Nếu không có bài kiểm tra, hiển thị nút hoàn thành bài học
      else {
        return ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () {
                  if (_isProcessing) return;

                  setState(() {
                    _isProcessing = true;
                  });

                  // Gọi hàm hoàn thành bài học
                  print('✅ Nhấn nút hoàn thành bài học');
                  widget.onComplete();

                  // Đặt thời gian chờ để tránh nhấn nhiều lần
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                    }
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.orange.withOpacity(0.5),
            disabledForegroundColor: Colors.white.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          child: _isProcessing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Đang xử lý...'),
                  ],
                )
              : Text('Hoàn thành bài học'),
        );
      }
    }

    // Nếu không có trường hợp nào khớp, trả về SizedBox không hiển thị gì
    return const SizedBox.shrink();
  }
}
