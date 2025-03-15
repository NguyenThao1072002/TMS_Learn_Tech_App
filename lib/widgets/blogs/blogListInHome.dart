import 'package:flutter/material.dart';

class BlogList extends StatelessWidget {
  final List<Map<String, dynamic>> blogs = [
    {
      "title": "Top Business Courses",
      "category": "Career Fasttrack",
      "views": "20k",
      "date": "28 Jan 2023",
      "image": "assets/images/blogs/blog_example1.jpg",
    },
    {
      "title": "Tracking Effects",
      "category": "Data Science",
      "views": "20k",
      "date": "28 Jan 2021",
      "image": "assets/images/blogs/blog_example1.jpg",
    },
    {
      "title": "AI in Healthcare",
      "category": "Artificial Intelligence",
      "views": "15k",
      "date": "15 Feb 2022",
      "image": "assets/images/blogs/blog_example1.jpg",
    },
    {
      "title": "Cybersecurity Trends",
      "category": "Cyber Security",
      "views": "18k",
      "date": "10 Mar 2023",
      "image": "assets/images/blogs/blog_example1.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề danh sách blog
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                "Blog được chú ý",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BlogList()),
                  );
                },
                child: Text(
                  "Xem tất cả >>",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Danh sách blogs cuộn ngang
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(blog: blog),
                    ),
                  );
                },
                child: Container(
                  width: 240,
                   margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  // margin: EdgeInsets.only(
                  //     left: 16, right: index == blogs.length - 1 ? 16 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          blog["image"],
                          width: 220,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog["category"],
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                            SizedBox(height: 4),
                            Text(
                              blog["title"],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.remove_red_eye,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(blog["views"],
                                    style: TextStyle(fontSize: 12)),
                                Spacer(),
                                Text(blog["date"],
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Màn hình chi tiết bài blog
class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;
  BlogDetailScreen({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blog["title"])),
      body: Center(
        child: Text("Chi tiết bài viết: ${blog["title"]}"),
      ),
    );
  }
}

