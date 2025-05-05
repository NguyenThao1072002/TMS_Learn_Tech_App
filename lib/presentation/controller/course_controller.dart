import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';

class CourseController {
  final CourseUseCase courseUseCase;
  final ValueNotifier<List<CourseCardModel>> filteredCourses =
      ValueNotifier([]);
  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final ValueNotifier<String> selectedFilter = ValueNotifier('all');
  final int itemsPerPage = 5;

  CourseController(this.courseUseCase);

  Future<void> loadCourses() async {
    final courses = await courseUseCase.getAllCourses();
    filteredCourses.value = courses;

    final popularCourses = await courseUseCase.getPopularCourses();
    final discountCourses = await courseUseCase.getDiscountCourses();
  }

  void filterCourses(String filter) {
    selectedFilter.value = filter;
    switch (filter) {
      case 'category':
        // Lọc theo danh mục
        break;
      case 'discount':
        // Lọc theo khóa học giảm giá
        filteredCourses.value = filteredCourses.value
            .where((course) => course.discountPercent > 0)
            .toList();
        break;
      case 'combo':
        // Lọc theo combo khóa học
        break;
      default:
        // Hiển thị tất cả khóa học
        loadCourses();
    }
    currentPage.value = 1; // Reset về trang đầu tiên khi lọc
  }

  void changePage(int page) {
    currentPage.value = page;
  }

  List<CourseCardModel> getCurrentPageCourses() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredCourses.value.sublist(
      startIndex,
      endIndex > filteredCourses.value.length
          ? filteredCourses.value.length
          : endIndex,
    );
  }

  int getTotalPages() {
    return (filteredCourses.value.length / itemsPerPage).ceil();
  }

  void dispose() {
    filteredCourses.dispose();
    currentPage.dispose();
    selectedFilter.dispose();
  }
}
