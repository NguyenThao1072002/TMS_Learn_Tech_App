import 'package:flutter/material.dart';

class CourseCategory extends StatefulWidget {
  @override
  _CourseCategoryState createState() => _CourseCategoryState();
}

class _CourseCategoryState extends State<CourseCategory> {
  final List<Map<String, String>> categories = [
    {"title": "Cyber Security", "courses": "145 Khoá"},
    {"title": "Data Science", "courses": "120 Khoá"},
    {"title": "Cloud Computing", "courses": "100 Khoá"},
    {"title": "Blockchain", "courses": "80 Khoá"},
    {"title": "Game Development", "courses": "95 Khoá"},
    {"title": "Big Data", "courses": "110 Khoá"},
    {"title": "Digital Marketing", "courses": "90 Khoá"},
    {"title": "Python", "courses": "130 Khoá"},
    {"title": "Machine Learning", "courses": "105 Khoá"},
    {"title": "AI & Deep Learning", "courses": "115 Khoá"},
    {"title": "Web Development", "courses": "140 Khoá"},
    {"title": "Mobile Development", "courses": "125 Khoá"},
  ];

  int? selectedIndex; // Lưu trạng thái ô được nhấn

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.4;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Danh mục khoá học",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 240, // Định kích thước để đủ chứa 3 hàng
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    List.generate((categories.length / 3).ceil(), (colIndex) {
                  int startIndex = colIndex * 3;
                  int endIndex = (startIndex + 3 > categories.length)
                      ? categories.length
                      : startIndex + 3;
                  List<Map<String, String>> columnItems =
                      categories.sublist(startIndex, endIndex);

                  return Container(
                    margin: EdgeInsets.only(right: 15),
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnItems.asMap().entries.map((entry) {
                        int index =
                            startIndex + entry.key; // Xác định index tổng
                        Map<String, String> category = entry.value;
                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });

                            // Chuyển màn hình sau một khoảng thời gian để thấy hiệu ứng
                            Future.delayed(Duration(milliseconds: 200), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailScreen(
                                      category: category["title"]!),
                                ),
                              ).then((_) {
                                // Reset lại trạng thái khi quay về
                                setState(() {
                                  selectedIndex = null;
                                });
                              });
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: itemWidth,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isSelected
                                  ? const Color.fromARGB(255, 171, 213, 248)
                                  : const Color.fromARGB(255, 225, 239, 250), // Màu xanh khi chọn
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  category["title"]!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black, // Đổi màu chữ
                                  ),
                                  maxLines: 1,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  category["courses"]!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.grey, // Đổi màu chữ
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final String category;
  CourseDetailScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Text("Chi tiết khoá học của $category"),
      ),
    );
  }
}
