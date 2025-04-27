import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/course/course_type_list.dart';

class DiscountCourses extends StatelessWidget {
  final List<CourseCardModel> courses;

  const DiscountCourses({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
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
