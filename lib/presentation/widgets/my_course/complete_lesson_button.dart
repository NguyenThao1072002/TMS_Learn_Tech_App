import 'package:flutter/material.dart';

class CompleteLessonButton extends StatelessWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const CompleteLessonButton({
    super.key,
    required this.onComplete,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.blue : Colors.green,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isCompleted ? 'Đã hoàn thành' : 'Hoàn thành bài học',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
