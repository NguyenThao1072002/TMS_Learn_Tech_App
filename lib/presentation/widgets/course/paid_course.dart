import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/presentation/screens/course/course_type_list.dart';

class PaidCourses extends StatelessWidget {
  final List<CourseCardModel> courses;

  const PaidCourses({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return CourseTypeList(
      title:
          "Khóa học của tôi", 
      courses: courses,
      buttonText: "Xem thêm>>", 
    );
  }
}
