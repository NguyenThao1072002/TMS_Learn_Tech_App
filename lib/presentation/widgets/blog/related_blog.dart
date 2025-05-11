import 'package:flutter/material.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/presentation/widgets/blog/blog_card.dart';
import 'package:tms_app/presentation/screens/blog/detail_blog.dart';

class RelatedBlog extends StatelessWidget {
  final Future<List<BlogCardModel>> relatedBlogsFuture;

  const RelatedBlog({
    Key? key,
    required this.relatedBlogsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlogCardModel>>(
      future: relatedBlogsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final relatedBlogs = snapshot.data ?? [];

        if (relatedBlogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bài viết liên quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240, // Chiều cao cố định cho danh sách cuộn ngang
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: relatedBlogs.length,
                itemBuilder: (context, index) {
                  final blog = relatedBlogs[index];
                  return Container(
                    width: 200, // Chiều rộng cố định cho mỗi mục
                    margin: const EdgeInsets.only(right: 12),
                    child: BlogCard(
                      blog: blog,
                      isHorizontal: false,
                      onTapById: () {
                        // Điều hướng đến chi tiết bài viết khi nhấp vào
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBlogScreen(
                              blogId: blog.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
