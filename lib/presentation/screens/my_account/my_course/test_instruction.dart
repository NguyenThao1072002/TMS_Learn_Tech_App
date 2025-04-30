import 'package:flutter/material.dart';

// Widget hiển thị hướng dẫn bài kiểm tra
class TestInstruction extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const TestInstruction({
    Key? key,
    required this.icon,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
