import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class SearchCoursesScreen extends StatefulWidget {
  @override
  _SearchCoursesScreenState createState() => _SearchCoursesScreenState();
}

class _SearchCoursesScreenState extends State<SearchCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1; // Trang hiện tại
  int itemsPerPage = 3; // Số khóa học mỗi trang

  List<Map<String, String>> courses = [
    {
      "title": "Machine Learning",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
    {
      "title": "Getting Started with ML",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
    {
      "title": "Introduction to Machine Learning",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
    {
      "title": "PG in Machine Learning",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
    {
      "title": "Machine Learning",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
    {
      "title": "Machine Learning Course",
      "rating": "4.5",
      "learners": "10.5k Learners",
      "image": "assets/images/courses/course_example.png",
    },
  ];

  List<Map<String, String>> filteredCourses = [];

//hiển thị khoá học theo phân trang
  List<Map<String, String>> _getCoursesForPage() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return filteredCourses.sublist(startIndex,
        endIndex > filteredCourses.length ? filteredCourses.length : endIndex);
  }

  @override
  void initState() {
    super.initState();
    filteredCourses = courses;
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= (courses.length / itemsPerPage).ceil()) {
      setState(() {
        currentPage = newPage;
      });
    }
  }

  void _searchCourses(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCourses = courses; // Nếu không nhập gì, hiển thị tất cả
      } else {
        filteredCourses = courses.where((course) {
          String title = course["title"]!.toLowerCase();
          String lowerQuery = query.toLowerCase();

          // Điều kiện tìm kiếm gần giống
          return title.contains(lowerQuery) ||
              title.similarityTo(lowerQuery) > 0.3; // Độ tương đồng > 30%
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 50, // Đặt chiều cao hợp lý
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchCourses,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 35,
                    ),
                    hintText: "Tìm khoá học...",
                    filled: true,
                    fillColor: Colors.white, // Màu nền trắng
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(color: Colors.grey.shade400), // Viền xám
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            ),

            // Danh sách khóa học
            Expanded(
              child: ListView.builder(
                itemCount: _getCoursesForPage().length,
                itemBuilder: (context, index) {
                  var course = _getCoursesForPage()[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(
                          6), // Thêm padding để tạo không gian
                      decoration: BoxDecoration(
                        color: Colors.white, // Màu nền trắng
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(0.4), // Màu đổ bóng nhẹ
                            blurRadius: 8, // Độ mờ của bóng
                            spreadRadius: 1, // Độ lan rộng của bóng
                            offset: const Offset(2, 4), // Hướng bóng đổ xuống
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                "assets/imgs/loading_placeholder.png"),
                            image: AssetImage(course["image"]!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          course["title"]!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.orange, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  course["rating"]!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Text(
                              course["learners"]!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          print("Clicked on ${course["title"]}");
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Phân trang
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => _changePage(currentPage - 1)
                        : null,
                    child: const Text("← Previous",
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  for (int i = 1;
                      i <= (courses.length / itemsPerPage).ceil();
                      i++)
                    TextButton(
                      onPressed: () => _changePage(i),
                      child: Text(
                        "$i",
                        style: TextStyle(
                          color: i == currentPage ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: i == currentPage
                            ? Colors.purple
                            : Colors.transparent,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        currentPage < (courses.length / itemsPerPage).ceil()
                            ? () => _changePage(currentPage + 1)
                            : null,
                    child: const Text("Next →",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
