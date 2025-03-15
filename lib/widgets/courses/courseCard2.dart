import 'package:flutter/material.dart';
import 'package:tms/screens/Courses/CourseDetail.dart';

class CourseCard2 extends StatefulWidget {
  final String imageAsset;
  final String title;
  final String instructor;
  final double rating;
  final int reviews;
  final int price;
  final int? oldPrice;

  const CourseCard2({
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
  _CourseCard2State createState() => _CourseCard2State();
}

class _CourseCard2State extends State<CourseCard2> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: _isHovered ? Colors.grey[300] : Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(
                imageAsset: widget.imageAsset,
                title: widget.title,
                instructor: widget.instructor,
                rating: widget.rating,
                reviews: widget.reviews,
                price: widget.price,
                oldPrice: widget.oldPrice,
              ),
            ),
          );
        },
        onHover: (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        },
        child: Container(
          width: 200,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Giữ chiều cao tối thiểu
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                child: Image.asset(
                  widget.imageAsset,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 6.0), // Giảm padding để giảm chiều cao
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6), // Giảm khoảng cách
                    Text(
                      widget.instructor,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6), // Giảm khoảng cách
                    Row(
                      children: [
                        Text(
                          widget.rating.toString(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        Text(
                          ' (${widget.reviews})',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Giảm khoảng cách
                    Row(
                      children: [
                        Text(
                          '${widget.price} đ',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.oldPrice != null) ...[
                          const SizedBox(width: 6), // Giảm khoảng cách
                          Text(
                            '${widget.oldPrice} đ',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
