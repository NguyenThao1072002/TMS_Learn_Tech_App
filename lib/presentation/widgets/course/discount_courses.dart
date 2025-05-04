import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/course/course_type_list.dart';

class DiscountCourses extends StatelessWidget {
  final List<CourseCardModel> courses;
  final bool isLoading; // Tham số để kiểm tra trạng thái loading
  final String? error; // Tham số để hiển thị lỗi

  const DiscountCourses({
    super.key,
    required this.courses,
    this.isLoading = false, // Mặc định không loading
    this.error, // Lỗi có thể là null nếu không có
  });

  @override
  Widget build(BuildContext context) {
    // Hiển thị khi đang loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị khi có lỗi
    if (error != null) {
      return Center(
        child: Text(
          'Không thể tải khóa học: $error',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    // Hiển thị danh sách khóa học nếu có dữ liệu
    if (courses.isEmpty) {
      return const Center(child: Text('Không có khóa học giảm giá.'));
    }

    return CourseTypeList(
      title: "Khoá học đang giảm giá",
      courses: courses,
      buttonText: "Xem thêm>>",
      onViewAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseScreen(
              initialFilter: 'discount',
            ),
          ),
        );
      },
    );
  }
}
