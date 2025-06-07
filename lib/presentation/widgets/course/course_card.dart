import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Xử lý phản hồi API

import 'package:tms_app/data/models/course/course_card_model.dart';

class CourseCard extends StatelessWidget {
  final CourseCardModel course;
  final int? selectedIndex;
  final void Function(CourseCardModel)? onTap;

  CourseCard({
    super.key,
    required this.course,
    required this.selectedIndex,
    required this.onTap,
  });

  final currencyFormatter = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == course.id;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Màu nền và màu chữ dựa vào chế độ
    final cardBgColor = isDarkMode 
        ? isSelected 
            ? Color(0xFF1E3A5F) // Màu xanh tối khi được chọn
            : Color(0xFF2A2D3E) // Màu xám đen khi không được chọn
        : isSelected 
            ? const Color.fromARGB(255, 231, 244, 255) 
            : Colors.white;

    return GestureDetector(
      onTap: () => onTap?.call(course),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: cardBgColor,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.15),
              blurRadius: isDarkMode ? 12 : 10,
              spreadRadius: isDarkMode ? 2 : 0,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? isDarkMode 
                    ? Color(0xFF4D88E0) 
                    : const Color(0xFF3498DB)
                : isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey.withOpacity(0.1),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: course.imageUrl.isNotEmpty &&
                          course.imageUrl.startsWith('http')
                      ? Image.network(
                          course.imageUrl,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                "Error loading image from URL: ${course.imageUrl}");
                            return Image.asset(
                              'assets/images/courses/courseExample.png',
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          course.imageUrl.isNotEmpty
                              ? course.imageUrl
                              : 'assets/images/courses/courseExample.png',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                "Error loading image from path: ${course.imageUrl}");
                            return Image.asset(
                              'assets/images/courses/courseExample.png',
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
                if (course.discountPercent > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "-${course.discountPercent}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.categoryName,
                          style: TextStyle(
                            fontSize: 12, 
                            color: isDarkMode ? Colors.lightBlue[300] : Colors.blue
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "GV: ${course.author}",
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDarkMode ? Colors.grey[400] : Colors.grey
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.book, 
                        size: 14, 
                        color: isDarkMode ? Colors.grey[400] : Colors.grey
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${course.totalLessons} Bài học",
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDarkMode ? Colors.grey[300] : Colors.black87
                        )
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.person, 
                        size: 14, 
                        color: isDarkMode ? Colors.grey[400] : Colors.grey
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${course.numberOfStudents} Học viên",
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDarkMode ? Colors.grey[300] : Colors.black87
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${course.averageRating}",
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDarkMode ? Colors.grey[300] : Colors.black87
                        ),
                      ),
                      const Spacer(),
                      if (course.cost > 0)
                        Text(
                          currencyFormatter.format(course.cost.toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        currencyFormatter.format(course.price.toInt()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.redAccent[100] : Colors.red,
                        ),
                      ),
                    ],
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
