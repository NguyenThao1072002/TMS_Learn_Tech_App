import 'package:flutter/material.dart';

class PopularCourses extends StatefulWidget {
  @override
  _PopularCoursesState createState() => _PopularCoursesState();
}

class _PopularCoursesState extends State<PopularCourses> {
  final List<Map<String, dynamic>> courses = [
    {
      "title": "Metaverse",
      "category": "Lập trình",
      "teacher": "TMS",
      "lessons": 45,
      "students": "10.5k",
      "rating": 4.6,
      "oldPrice": "",
      "newPrice": "700.000 đ",
      "discount": null,
      "image": "assets/images/courses/courseExample.png",
    },
    {
      "title": "AI & Deep Learning",
      "category": "Trí tuệ nhân tạo",
      "teacher": "Dr. John",
      "lessons": 50,
      "students": "12k",
      "rating": 4.8,
      "oldPrice": "1.200.000 đ",
      "newPrice": "850.000 đ",
      "discount": "-29%",
      "image": "assets/images/courses/courseExample.png",
    },
    {
      "title": "Metaverse",
      "category": "Lập trình",
      "teacher": "TMS",
      "lessons": 45,
      "students": "10.5k",
      "rating": 4.6,
      "oldPrice": "1.000.000 đ",
      "newPrice": "700.000 đ",
      "discount": "-30%",
      "image": "assets/images/courses/courseExample.png",
    },
    {
      "title": "AI & Deep Learning",
      "category": "Trí tuệ nhân tạo",
      "teacher": "Dr. John",
      "lessons": 50,
      "students": "12k",
      "rating": 4.8,
      "oldPrice": "",
      "newPrice": "850.000 đ",
      "discount": "",
      "image": "assets/images/courses/courseExample.png",
    },
    {
      "title": "Metaverse",
      "category": "Lập trình",
      "teacher": "TMS",
      "lessons": 45,
      "students": "10.5k",
      "rating": 4.6,
      "oldPrice": "1.000.000 đ",
      "newPrice": "700.000 đ",
      "discount": "-30%",
      "image": "assets/images/courses/courseExample.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề "Các khoá học phổ biến" + "Xem tất cả"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                "Các khoá học phổ biến",
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
                    MaterialPageRoute(builder: (context) => CourseListScreen()),
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
        // Danh sách khoá học cuộn ngang
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Container(
                width: 240,
                 margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(1, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.asset(
                            course["image"],
                            width: 240,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (course["discount"] != null &&
                            course["discount"] != "")
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                course["discount"],
                                style: TextStyle(
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
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                course["category"],
                                style:
                                    TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                              Spacer(),
                              Text(
                                "GV: ${course["teacher"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            course["title"],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.book, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("${course["lessons"]} Bài học",
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(width: 10),
                              Icon(Icons.person, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("${course["students"]} Học viên",
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                "${course["rating"]}",
                                style: TextStyle(fontSize: 12),
                              ),
                              Spacer(),
                              if (course["oldPrice"] != null &&
                                  course["oldPrice"] != "")
                                Text(
                                  course["oldPrice"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 6),
                              Text(
                                course["newPrice"],
                                style: TextStyle(
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
              );
            },
          ),
        ),
      ],
    );
  }
  //       ),
  //     ),
  //   ],
  // );
  // }
}

// Màn hình danh sách khóa học
class CourseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách khoá học")),
      body: Center(
        child: Text("Danh sách tất cả các khoá học"),
      ),
    );
  }
}
