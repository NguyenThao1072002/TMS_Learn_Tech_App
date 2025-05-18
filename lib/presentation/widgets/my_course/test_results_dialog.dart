import 'package:flutter/material.dart';

class TestResultsDialog extends StatelessWidget {
  final double result;
  final int totalQuestions;
  final double pointsPerQuestion;
  final bool isPassed;
  final VoidCallback onContinue;
  final VoidCallback onRetry;
  final VoidCallback onReview;

  const TestResultsDialog({
    Key? key,
    required this.result,
    required this.totalQuestions,
    required this.pointsPerQuestion,
    required this.isPassed,
    required this.onContinue,
    required this.onRetry,
    required this.onReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Test result icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  size: 50,
                  color: isPassed ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result title
            Text(
              isPassed ? 'Chúc mừng!' : 'Chưa đạt yêu cầu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            // Result message
            Text(
              isPassed
                  ? 'Bạn đã hoàn thành bài kiểm tra thành công.'
                  : 'Bạn cần ôn tập lại và thử lại bài kiểm tra.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Score details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreItem('Điểm số',
                      '$result/${totalQuestions * pointsPerQuestion}'),
                  _buildScoreItem('Câu hỏi', '$totalQuestions câu'),
                  _buildScoreItem('Tỉ lệ đạt',
                      '${((result / (totalQuestions * pointsPerQuestion)) * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPassed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Làm lại'),
                    ),
                  ),
                if (!isPassed) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isPassed ? onContinue : onReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPassed ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isPassed ? 'Tiếp tục' : 'Xem lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
