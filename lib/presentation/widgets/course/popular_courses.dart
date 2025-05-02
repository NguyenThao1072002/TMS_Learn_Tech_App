import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/course/course_type_list.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class PopularCourses extends StatelessWidget {
  final List<CourseCardModel> courses;
  final bool isLoading;
  final String? error;

  const PopularCourses({
    super.key,
    required this.courses,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Không thể tải khoá học: $error",
            style: AppStyles.errorText,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (courses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Không có khoá học phổ biến",
            style: AppStyles.subText,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return CourseTypeList(
      title: "Khoá học phổ biến",
      courses: courses,
      buttonText: "Xem thêm>>",
      onViewAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseScreen(
              initialFilter: 'popular',
            ),
          ),
        );
      },
    );
  }
}
