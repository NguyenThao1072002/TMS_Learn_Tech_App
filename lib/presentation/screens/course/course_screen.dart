import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/widgets/component/search_widget.dart';
import 'package:tms_app/presentation/widgets/component/pagination.dart';
import 'course_list.dart';

class CourseScreen extends StatefulWidget {
  final String? initialFilter;
  final String? category;

  const CourseScreen({
    super.key,
    this.initialFilter,
    this.category,
  });

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late final CourseController _controller;

  @override
  void initState() {
    super.initState();
    final courseUseCase = GetIt.instance<CourseUseCase>();
    _controller = CourseController(courseUseCase);
    _controller.loadCourses();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Danh sách khóa học",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<CourseCardModel>>(
        valueListenable: _controller.filteredCourses,
        builder: (context, courses, _) {
          return Column(
            children: [
              const SearchWidget(),
              _buildFilterSection(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CourseList(
                        courses: _controller.getCurrentPageCourses(),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _controller.currentPage,
                        builder: (context, currentPage, _) {
                          return PaginationWidget(
                            currentPage: currentPage,
                            totalPages: _controller.getTotalPages(),
                            onPageChanged: _controller.changePage,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton("Danh mục", 'category'),
          _buildFilterButton("Giảm giá", 'discount'),
          _buildFilterButton("Combo khóa học", 'combo'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter) {
    return ValueListenableBuilder<String>(
      valueListenable: _controller.selectedFilter,
      builder: (context, selectedFilter, _) {
        final isSelected = selectedFilter == filter;
        return ElevatedButton(
          onPressed: () => _controller.filterCourses(filter),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue[900] : Colors.blue,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
