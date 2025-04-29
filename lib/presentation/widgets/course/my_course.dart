import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/widgets/course/course_card_simple.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/my_course.dart';

class MyCourses extends StatelessWidget {
  final List<CourseCardModel> courses;

  const MyCourses({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề và nút xem thêm
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Khoá học của tôi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCourseScreen(),
                  ),
                );
              },
              child: const Text(
                "Xem thêm >>",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Danh sách khóa học theo chiều ngang
        SizedBox(
          height: 200, // Tăng từ 184px lên 200px để đảm bảo không bị overflow
          child: courses.isEmpty
              ? const Center(
                  child: Text(
                    "Bạn chưa đăng ký khóa học nào",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return CourseCardSimple(
                      course: courses[index],
                      onTap: (course) {
                        // Điều hướng đến trang Khóa học của tôi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyCourseScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
