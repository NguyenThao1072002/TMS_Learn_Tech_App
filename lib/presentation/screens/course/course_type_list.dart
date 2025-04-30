import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_detail.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';

class CourseTypeList extends StatelessWidget {
  final String title;
  final List<CourseCardModel> courses;
  final String buttonText;
  final VoidCallback? onViewAll;

  const CourseTypeList({
    super.key,
    required this.title,
    required this.courses,
    required this.buttonText,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    buttonText, // Văn bản nút "Xem tất cả"
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 290, // Tăng chiều cao để phù hợp với card khóa học mới
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Cuộn ngang
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index]; // Lấy thông tin khóa học

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 4.0 : 0.0,
                  right: index == courses.length - 1 ? 0.0 : 0.0,
                ),
                child: CourseCard(
                  course: course,
                  selectedIndex: null, // Có thể quản lý chỉ mục được chọn ở đây
                  onTap: (course) {
                    // Hành động khi người dùng nhấn vào khóa học (ví dụ: điều hướng đến chi tiết khóa học)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
