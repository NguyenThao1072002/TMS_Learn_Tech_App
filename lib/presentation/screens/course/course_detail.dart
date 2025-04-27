import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart'; // Đảm bảo import đúng

class CourseDetailScreen extends StatelessWidget {
  final CourseCardModel
      course; // Nhận đối tượng CourseCardDTO thay vì các tham số riêng lẻ

  const CourseDetailScreen(
      {super.key,
      required this.course}); // Truyền đối tượng course vào constructor

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình hiện tại
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title), // Lấy tiêu đề từ course
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                course.imageUrl,
                height: 200,
                width: screenWidth - 32, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/images/courses/courseExample.png", 
                  width: screenWidth - 32, 
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              course.title, 
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Giảng viên: ${course.author}', 
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  course.averageRating.toString(), 
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.star, color: Colors.orange, size: 14),
                Text(
                  ' (${course.numberOfStudents})',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${course.price} đ', 
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...[
                  const SizedBox(width: 8),
                  Text(
                    '${course.cost} đ',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
