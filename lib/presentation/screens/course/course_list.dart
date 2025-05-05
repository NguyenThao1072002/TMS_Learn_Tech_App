import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';
import 'package:tms_app/presentation/screens/course/course_detail.dart';

class CourseList extends StatelessWidget {
  final List<CourseCardModel> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseCard(
          course: course,
          selectedIndex: null,
          onTap: (course) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(course: course),
              ),
            );
          },
        );
      },
    );
  }
}
