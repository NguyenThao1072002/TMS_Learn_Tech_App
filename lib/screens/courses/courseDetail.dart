import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String instructor;
  final double rating;
  final int reviews;
  final int price;
  final int? oldPrice;

  const CourseDetailScreen({
    Key? key,
    required this.imageAsset,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviews,
    required this.price,
    this.oldPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageAsset,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Instructor: $instructor',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.star, color: Colors.orange, size: 14),
                Text(
                  ' ($reviews)',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$price đ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (oldPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$oldPrice đ',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
