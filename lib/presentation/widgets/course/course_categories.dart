import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/category_model.dart';
import 'package:tms_app/data/repositories/category_repository_impl.dart';
import 'package:tms_app/data/services/category_service.dart';
import 'package:tms_app/domain/repositories/category_repository.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'dart:convert';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late Future<List<CategoryModel>> _categoriesFuture;
  int? selectedIndex; // Lưu trạng thái ô được nhấn

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    CategoryUseCase? categoryUseCase;

    // Thử lấy CategoryUseCase trực tiếp từ sl instance đã được export
    try {
      // Cố gắng lấy từ dependency injection
      categoryUseCase = sl<CategoryUseCase>();
    } catch (e) {
      print('Error getting CategoryUseCase from GetIt: $e');
      // Nếu không thể lấy được từ GetIt, tạo mới thủ công
      try {
        final categoryService = CategoryService();
        final categoryRepository =
            CategoryRepositoryImpl(categoryService: categoryService);
        categoryUseCase = CategoryUseCase(categoryRepository);
        print('Created CategoryUseCase manually');
      } catch (e) {
        print('Error creating CategoryUseCase manually: $e');
      }
    }

    if (categoryUseCase != null) {
      // Không xử lý encoding nữa, trực tiếp lấy dữ liệu
      _categoriesFuture = categoryUseCase.getCategories();
    } else {
      // Fallback: load mẫu dữ liệu tĩnh nếu không lấy được usecase
      print('Using static categories as fallback');
      _categoriesFuture = Future.value(_getStaticCategories());
    }
  }

  List<CategoryModel> _getStaticCategories() {
    return [
      CategoryModel(
          id: 1,
          name: "Cyber Security",
          level: 3,
          type: "COURSE",
          description: "Khóa học về bảo mật thông tin",
          itemCount: 145,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 2,
          name: "Data Science",
          level: 3,
          type: "COURSE",
          description: "Khóa học về khoa học dữ liệu",
          itemCount: 120,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 3,
          name: "Cloud Computing",
          level: 3,
          type: "COURSE",
          description: "Khóa học về điện toán đám mây",
          itemCount: 100,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 4,
          name: "Blockchain",
          level: 3,
          type: "COURSE",
          description: "Khóa học về blockchain",
          itemCount: 80,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth =
        MediaQuery.of(context).size.width * 0.42; // Tăng kích thước mỗi item

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Danh mục khoá học",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      "Lỗi: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 260,
                  child: Center(
                    child: Text("Không có danh mục nào"),
                  ),
                );
              }

              final categories = snapshot.data!;

              return SizedBox(
                height: 290, // Tăng chiều cao để có thêm không gian
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate((categories.length / 3).ceil(),
                        (colIndex) {
                      int startIndex = colIndex * 3;
                      int endIndex = (startIndex + 3 > categories.length)
                          ? categories.length
                          : startIndex + 3;
                      List<CategoryModel> columnItems =
                          categories.sublist(startIndex, endIndex);

                      return Container(
                        margin: const EdgeInsets.only(
                            right: 18), // Tăng khoảng cách giữa các cột
                        width: itemWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: columnItems.asMap().entries.map((entry) {
                            int index =
                                startIndex + entry.key; // Xác định index tổng
                            CategoryModel category = entry.value;
                            bool isSelected = selectedIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });

                                // Chuyển sang màn hình chi tiết sau một khoảng thời gian để thấy hiệu ứng
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseScreen(
                                        initialFilter: 'category',
                                        category: category.name,
                                      ),
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
                                duration: const Duration(milliseconds: 200),
                                width: itemWidth,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6), // Tăng margin dọc
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(12), // Tăng bo góc
                                  color: isSelected
                                      ? const Color.fromARGB(255, 171, 213, 248)
                                      : const Color.fromARGB(
                                          255, 225, 239, 250),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14), // Tăng padding
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87, // Màu đen nhẹ hơn
                                        fontFamily: 'Roboto',
                                        height: 1.3, // Tăng chiều cao dòng
                                        letterSpacing:
                                            0.1, // Giảm khoảng cách chữ
                                      ),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                        height: 5), // Tăng khoảng cách
                                    Text(
                                      "${category.itemCount} Khoá",
                                      style: TextStyle(
                                        fontSize: 13, // Tăng kích thước
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white.withOpacity(
                                                0.9) // Màu trắng đục
                                            : Colors
                                                .grey[600], // Màu xám đậm hơn
                                        fontFamily: 'Roboto',
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final String category;
  const CourseDetailScreen({super.key, required this.category});

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
