import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MyCourseCard extends StatelessWidget {
  final String courseTitle;
  final String courseImage;
  final String timeLeft;
  final double progress;
  final VoidCallback onTap;

  const MyCourseCard({
    Key? key,
    required this.courseTitle,
    required this.courseImage,
    required this.timeLeft,
    required this.progress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tiêu đề + Thời gian còn lại
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        courseTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          timeLeft,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Hình ảnh khóa học + Vòng tròn tiến trình
                Row(
                  children: [
                    /// Hình ảnh khóa học
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        courseImage,
                        height: 80,
                        width: MediaQuery.of(context).size.width *
                            0.4, // Chiếm 50% chiều rộng
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// Vòng tròn tiến trình
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 82.0), // Thêm khoảng cách bên phải
                        child: CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 8.0,
                          percent: progress / 100,
                          center: Text(
                            '${progress.toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.grey[300]!,
                          progressColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          /// Đường chỉ full chiều rộng
          Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),

          /// Nút "Vào học"
          Center(
            child: TextButton(
              onPressed: onTap,
              child: const Text(
                "Vào học",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
