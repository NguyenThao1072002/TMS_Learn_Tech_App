import 'package:flutter/material.dart';

class BlogCard extends StatefulWidget {
  final String imageAsset;
  final String title;
  final String category;
  final String date;

  const BlogCard({
    Key? key,
    required this.imageAsset,
    required this.title,
    required this.category,
    required this.date,
  }) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: _isHovered ? Colors.grey[300] : Colors.white,
      child: InkWell(
        onTap: () {
          // Điều hướng đến màn hình chi tiết blog
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  widget.imageAsset,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                        maxLines: 2, // Giới hạn số dòng của tiêu đề
                        overflow: TextOverflow
                            .ellipsis, // Hiển thị dấu ba chấm nếu vượt quá
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1, // Giới hạn số dòng của category
                        overflow: TextOverflow
                            .ellipsis, // Hiển thị dấu ba chấm nếu vượt quá
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
