import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';

class CourseCardSimple extends StatelessWidget {
  final CourseCardModel course;
  final void Function(CourseCardModel)? onTap;

  const CourseCardSimple({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(course),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 240, 246, 251),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh khóa học
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                course.imageUrl.isNotEmpty
                    ? course.imageUrl
                    : 'assets/images/courses/courseExample.png',
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/courses/courseExample.png',
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            // Thông tin khóa học
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên khóa học
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tên giảng viên
                  Text(
                    "GV: ${course.author}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
