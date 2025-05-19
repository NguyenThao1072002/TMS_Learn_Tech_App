import 'package:flutter/material.dart';

class CompleteLessonButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback? onStartTest;
  final bool hasTest;

  const CompleteLessonButton({
    Key? key,
    required this.isCompleted,
    required this.onComplete,
    this.onStartTest,
    this.hasTest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.play_arrow,
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
                    isCompleted
                        ? 'Đã hoàn thành bài học'
                        : 'Chưa hoàn thành bài học',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCompleted)
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
            if (isCompleted && hasTest)
              ElevatedButton.icon(
                onPressed: onStartTest,
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
              )
            else if (!isCompleted)
              ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Hoàn thành bài học'),
              ),
          ],
        ),
      ),
    );
  }
}
