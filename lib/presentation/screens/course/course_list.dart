import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/screens/course/course_detail.dart';
import 'package:tms_app/presentation/widgets/component/pagination.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';

// Widget để hiển thị danh sách khóa học, được sử dụng trong CourseScreen
class CourseList extends StatelessWidget {
  final List<CourseCardModel> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return courses.isEmpty
        ? const Center(
            child:
                Text('Không có khóa học nào', style: TextStyle(fontSize: 16)),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(
                course: course,
                selectedIndex: null,
                onTap: (course) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
              );
            },
          );
  }
}

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late CourseController courseController;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    courseController = CourseController(
      sl<CourseUseCase>(),
      categoryUseCase: sl<CategoryUseCase>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      courseController.loadCourses();
    });
  }

  @override
  void dispose() {
    courseController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khóa học'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khóa học...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    courseController.searchCourses('');
                  },
                ),
              ),
              onSubmitted: (value) => courseController.searchCourses(value),
            ),
          ),

          // Nội dung chính
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: courseController.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder(
                  valueListenable: courseController.filteredCourses,
                  builder: (context, courses, child) {
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không tìm thấy khóa học nào',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Hiển thị danh sách khóa học
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CourseCard(
                                  course: courses[index],
                                  selectedIndex: null,
                                  onTap: (course) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseDetailScreen(course: course),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // Phân trang
                        ValueListenableBuilder(
                          valueListenable: courseController.currentPage,
                          builder: (context, currentPage, child) {
                            return ValueListenableBuilder(
                              valueListenable: courseController.totalPages,
                              builder: (context, totalPages, child) {
                                return ValueListenableBuilder(
                                  valueListenable:
                                      courseController.totalElements,
                                  builder: (context, totalElements, child) {
                                    if (totalPages <= 1) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: PaginationWidget(
                                        currentPage: currentPage,
                                        totalPages: totalPages,
                                        totalElements: totalElements,
                                        itemsPerPage:
                                            courseController.itemsPerPage,
                                        onPageChanged: (page) {
                                          courseController.changePage(page);
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
