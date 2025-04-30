import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/models/course_card_model.dart';

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
    bool isSelected = selectedIndex ==
        course.id; // Kiểm tra xem có phải khóa học này được chọn không

    return GestureDetector(
      onTap: () => onTap?.call(course),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? const Color.fromARGB(255, 231, 244, 255)
              : const Color.fromARGB(255, 240, 246, 251),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
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
                // Nếu khóa học có giảm giá, hiển thị thông báo giảm giá
                if (course.discountPercent >
                    0) // Kiểm tra discountPercent lớn hơn 0
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
                        "-${course.discountPercent}%", // Hiển thị phần trăm giảm giá
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
                          style:
                              const TextStyle(fontSize: 12, color: Colors.blue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "GV: ${course.author}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.book, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${course.totalLessons} Bài học",
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${course.numberOfStudents} Học viên",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${course.averageRating}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      if (course.cost > 0)
                        Text(
                          currencyFormatter.format(
                              course.cost.toInt()), // ✅ Hiển thị có dấu chấm
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        currencyFormatter.format(
                            course.price.toInt()), // ✅ Hiển thị có dấu chấm
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
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
