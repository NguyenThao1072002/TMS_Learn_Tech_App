import 'package:flutter/material.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';

class CourseController {
  final CourseUseCase courseUseCase;
  final CategoryUseCase? categoryUseCase;
  final ValueNotifier<List<CourseCardModel>> filteredCourses =
      ValueNotifier([]);
  final ValueNotifier<List<CourseCardModel>> allCourses = ValueNotifier([]);
  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final ValueNotifier<String> selectedFilter = ValueNotifier('all');
  final ValueNotifier<List<CourseCategory>> categories = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedCategoryIds = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<Map<String, bool>> discountRanges = ValueNotifier({
    '0-10%': false,
    '10-30%': false,
    '30-50%': false,
    '50-70%': false,
    '70%+': false,
  });
  final int itemsPerPage = 5;

  CourseController(this.courseUseCase, {this.categoryUseCase});

  Future<void> loadCourses() async {
    isLoading.value = true;
    final courses = await courseUseCase.getAllCourses();
    allCourses.value = courses;
    filteredCourses.value = courses;
    isLoading.value = false;

    // Load các danh mục khóa học nếu có categoryUseCase
    if (categoryUseCase != null) {
      await loadCategories();
    }
  }

  Future<void> loadCategories() async {
    try {
      final courseCategories = await categoryUseCase!.getCourseCategories();
      categories.value =
          courseCategories.where((cat) => cat.type == "COURSE").toList();
    } catch (e) {
      print('Error loading categories: $e');
      categories.value = [];
    }
  }

  void filterCourses(String filter) {
    selectedFilter.value = filter;

    // Reset selected categories when changing filter type
    if (filter != 'category') {
      selectedCategoryIds.value = [];
    }

    // Reset discount ranges when changing filter type
    if (filter != 'discount') {
      resetDiscountRanges();
    }

    switch (filter) {
      case 'category':
        // Lọc theo danh mục - việc lọc cụ thể sẽ được xử lý bởi filterByCategories()
        break;
      case 'discount':
        // Lọc theo khóa học giảm giá
        _loadDiscountCourses();
        break;
      case 'combo':
        // Lọc theo combo khóa học
        // Giả sử combo khóa học có một field để xác định
        filteredCourses.value = allCourses.value
            .where((course) => course.isCombo ?? false)
            .toList();
        break;
      default:
        // Hiển thị tất cả khóa học
        filteredCourses.value = List.from(allCourses.value);
    }
    currentPage.value = 1; // Reset về trang đầu tiên khi lọc
  }

  void filterByCategories(List<int> categoryIds) {
    selectedCategoryIds.value = categoryIds;
    if (categoryIds.isEmpty) {
      // Nếu không có danh mục nào được chọn, hiển thị tất cả
      filteredCourses.value = List.from(allCourses.value);
    } else {
      // Lọc các khóa học thuộc danh mục được chọn đầu tiên (API chỉ hỗ trợ lọc theo 1 danh mục)
      _loadCoursesByCategory(categoryIds.first);
    }
  }

  Future<void> _loadCoursesByCategory(int categoryId) async {
    isLoading.value = true;
    try {
      final categoryCourses =
          await courseUseCase.getFilteredCourses(categoryId: categoryId);
      filteredCourses.value = categoryCourses;
    } catch (e) {
      print('Error loading category courses: $e');
      filteredCourses.value = [];
    }
    isLoading.value = false;
    currentPage.value = 1; // Reset về trang đầu tiên
  }

  void changePage(int page) {
    currentPage.value = page;
  }

  List<CourseCardModel> getCurrentPageCourses() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (filteredCourses.value.isEmpty) {
      return [];
    }

    if (startIndex >= filteredCourses.value.length) {
      return [];
    }

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

  Future<void> _loadDiscountCourses() async {
    isLoading.value = true;
    try {
      // Determine the selected discount ranges
      final selectedRanges = discountRanges.value.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      print('===== DEBUG DISCOUNT FILTERING =====');
      print('Selected ranges: $selectedRanges');

      if (selectedRanges.isEmpty) {
        // If no specific range is selected, get all discount courses
        print(
            'Không có khoảng giảm giá nào được chọn, lấy tất cả khóa học giảm giá');
        final discountCourses =
            await courseUseCase.getFilteredCourses(type: 'discount');
        print('Tổng số khóa học giảm giá: ${discountCourses.length}');

        // Print discount for each course
        for (var course in discountCourses) {
          print(
              'Khóa học: ${course.title}, Giảm giá: ${course.discountPercent}%');
        }

        filteredCourses.value = discountCourses;
      } else {
        // If specific ranges are selected, filter by those ranges
        final courses = <CourseCardModel>[];

        for (final range in selectedRanges) {
          int? minDiscount;
          int? maxDiscount;

          if (range == '0-10%') {
            minDiscount = 0;
            maxDiscount = 10;
            print('Đang lọc khóa học giảm giá từ 0-10%');
          } else if (range == '10-30%') {
            minDiscount = 10;
            maxDiscount = 30;
          } else if (range == '30-50%') {
            minDiscount = 30;
            maxDiscount = 50;
          } else if (range == '50-70%') {
            minDiscount = 50;
            maxDiscount = 70;
          } else if (range == '70%+') {
            minDiscount = 70;
            maxDiscount = null;
          }

          print('Lọc khoảng $range: min=$minDiscount, max=$maxDiscount');

          final rangeDiscountCourses = await courseUseCase.getFilteredCourses(
            type: 'discount',
            minDiscount: minDiscount,
            maxDiscount: maxDiscount,
          );

          print(
              'Tìm thấy ${rangeDiscountCourses.length} khóa học trong khoảng $range');
          // In ra chi tiết các khóa học trong khoảng này
          for (var course in rangeDiscountCourses) {
            print(
                'ID: ${course.id}, Tiêu đề: ${course.title}, Giảm giá: ${course.discountPercent}%');
          }

          // Add unique courses
          for (final course in rangeDiscountCourses) {
            if (!courses.any((c) => c.id == course.id)) {
              courses.add(course);
            }
          }
        }

        filteredCourses.value = courses;
        print('Tổng cộng ${filteredCourses.value.length} khóa học sau khi lọc');
      }
      print('===== KẾT THÚC DEBUG =====');
    } catch (e) {
      print('Error loading discount courses: $e');
      filteredCourses.value = [];
    }
    isLoading.value = false;
    currentPage.value = 1; // Reset về trang đầu tiên
  }

  void resetDiscountRanges() {
    discountRanges.value = {
      '0-10%': false,
      '10-30%': false,
      '30-50%': false,
      '50-70%': false,
      '70%+': false,
    };
  }

  void updateDiscountRange(String range, bool value) {
    final updatedRanges = Map<String, bool>.from(discountRanges.value);
    updatedRanges[range] = value;
    discountRanges.value = updatedRanges;

    if (selectedFilter.value == 'discount') {
      _loadDiscountCourses();
    }
  }

  // Thêm phương thức tìm kiếm khóa học
  void searchCourses(String query) async {
    isLoading.value = true;
    try {
      if (query.isEmpty) {
        // Nếu query rỗng, hiển thị tất cả khóa học
        filteredCourses.value = List.from(allCourses.value);
      } else {
        // Sử dụng getAllCourses với tham số search giống như đề thi
        print('Đang tìm kiếm khóa học với từ khóa: "$query"');
        final results = await courseUseCase.getAllCourses(search: query);
        print(
            'Tìm thấy ${results.length} khóa học phù hợp với từ khóa "$query"');
        filteredCourses.value = results;
      }
    } catch (e) {
      print('Lỗi khi tìm kiếm khóa học: $e');
      // Fallback: lọc offline nếu API gặp lỗi
      if (query.isNotEmpty) {
        final normalizedQuery = query.toLowerCase().trim();
        final results = allCourses.value.where((course) {
          final title = course.title.toLowerCase();
          final author = course.author.toLowerCase();
          return title.contains(normalizedQuery) ||
              author.contains(normalizedQuery);
        }).toList();
        filteredCourses.value = results;
      }
    } finally {
      currentPage.value = 1; // Reset về trang đầu tiên khi tìm kiếm
      isLoading.value = false;
    }
  }

  void dispose() {
    filteredCourses.dispose();
    allCourses.dispose();
    currentPage.dispose();
    selectedFilter.dispose();
    categories.dispose();
    selectedCategoryIds.dispose();
    isLoading.dispose();
    discountRanges.dispose();
  }
}
