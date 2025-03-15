import 'package:flutter/material.dart';
import 'courseCard2.dart';

class CourseList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> courses;
  final Color titleColor;

  const CourseList({
    Key? key,
    required this.title,
    required this.courses,
    this.titleColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Padding(
                padding: EdgeInsets.only(
                  left:
                      index == 0 ? 0 : 12, // Giảm khoảng cách giữa các phần tử
                  right: 0, // Thêm khoảng cách bên phải cho tất cả các phần tử
                ),
                child: CourseCard2(
                  imageAsset: course['imageAsset'],
                  title: course['title'],
                  instructor: course['instructor'],
                  rating: course['rating'],
                  reviews: course['reviews'],
                  price: course['price'],
                  oldPrice: course['oldPrice'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
