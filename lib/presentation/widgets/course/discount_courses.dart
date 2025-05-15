import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/course/course_type_list.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class DiscountCourses extends StatelessWidget {
  final List<CourseCardModel> courses;
  final bool isLoading;
  final String? error;

  const DiscountCourses({
    super.key,
    required this.courses,
    this.isLoading = false,
    this.error,
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
          'Không thể tải khóa học: ${error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Hiển thị danh sách khóa học nếu có dữ liệu
    if (courses.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const Text(
                'Hiện chưa có khóa học giảm giá nào!',
                style: AppStyles.subText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy quay lại sau để xem các chương trình khuyến mãi mới nhất từ chúng tôi.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseScreen(),
                    ),
                  );
                },
                child: const Text('Xem các khóa học khác'),
              ),
            ],
          ),
        ),
      );
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
