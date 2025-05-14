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
  final ValueNotifier<int> totalPages = ValueNotifier(1);
  final ValueNotifier<int> totalElements = ValueNotifier(0);
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
  final int itemsPerPage = 10; // Mặc định hiển thị 10 khóa học/trang như API
  int? _accountId; // Lưu accountId để sử dụng khi gọi API

  CourseController(this.courseUseCase, {this.categoryUseCase, int? accountId}) {
    _accountId = accountId;
  }

  set accountId(int? id) {
    _accountId = id;
  }

  Future<void> loadCourses() async {
    isLoading.value = true;
    try {
      // Reset filter về 'all' khi refresh
      selectedFilter.value = 'all';
      // Reset trang về 1
      currentPage.value = 1;
      // Reset các bộ lọc khác
      selectedCategoryIds.value = [];
      resetDiscountRanges();

      // Sử dụng phương thức phân trang mới
      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: 'popular',
        page: 0, // Trang đầu tiên (API bắt đầu từ 0)
        size: itemsPerPage,
        accountId: _accountId,
      );

      allCourses.value = paginationResponse.content;
      filteredCourses.value = paginationResponse.content;
      totalPages.value =
          paginationResponse.totalPages > 0 ? paginationResponse.totalPages : 1;
      totalElements.value = paginationResponse.totalElements;

      print('Đã tải ${paginationResponse.content.length} khóa học');
      print('Tổng số trang: ${paginationResponse.totalPages}');
      print('Tổng số khóa học: ${paginationResponse.totalElements}');
    } catch (e) {
      print('Lỗi khi tải khóa học: $e');
      // Trong trường hợp lỗi, thử sử dụng phương thức cũ
      final courses = await courseUseCase.getAllCourses(accountId: _accountId);
      allCourses.value = courses;
      filteredCourses.value = courses;
    } finally {
      isLoading.value = false;
    }

    // Tải các danh mục khóa học nếu có categoryUseCase
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

    _loadFilteredCourses();
  }

  Future<void> _loadFilteredCourses() async {
    isLoading.value = true;
    try {
      currentPage.value = 1; // Reset về trang đầu tiên khi lọc

      // Lưu lại giá trị filter hiện tại để đảm bảo không bị thay đổi
      final currentFilter = selectedFilter.value;

      String type = currentFilter;
      // Nếu filter là "all" thì sử dụng "popular"
      if (type == 'all') {
        type = 'popular';
      }

      List<int>? categoryIds;

      switch (currentFilter) {
        case 'category':
          // Nếu có danh mục được chọn
          if (selectedCategoryIds.value.isNotEmpty) {
            categoryIds = selectedCategoryIds.value;
          }
          break;
        case 'discount':
          type = 'discount';
          break;
        case 'combo':
          // Lọc theo combo khóa học (giả sử API hỗ trợ tham số type=combo)
          type = 'combo';
          break;
        default:
          type = 'popular';
      }

      print('Lọc khóa học với filter: $currentFilter, type: $type');

      // Sử dụng API phân trang với các bộ lọc
      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: type,
        categoryIds: categoryIds,
        page: 0, // Trang đầu tiên (API bắt đầu từ 0)
        size: itemsPerPage,
        accountId: _accountId,
      );

      filteredCourses.value = paginationResponse.content;
      totalPages.value =
          paginationResponse.totalPages > 0 ? paginationResponse.totalPages : 1;
      totalElements.value = paginationResponse.totalElements;

      // Đảm bảo giá trị filter vẫn được giữ nguyên
      selectedFilter.value = currentFilter;

      // Xử lý lọc giảm giá riêng cho trường hợp discount
      if (currentFilter == 'discount') {
        _processDiscountFilters();
      }
    } catch (e) {
      print('Lỗi khi lọc khóa học: $e');
      // Fallback cho trường hợp lỗi
      switch (selectedFilter.value) {
        case 'discount':
          _loadDiscountCourses();
          break;
        case 'category':
          if (selectedCategoryIds.value.isNotEmpty) {
            _loadCoursesByCategories(selectedCategoryIds.value);
          } else {
            filteredCourses.value = List.from(allCourses.value);
          }
          break;
        default:
          filteredCourses.value = List.from(allCourses.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategories(List<int> categoryIds) {
    selectedCategoryIds.value = categoryIds;
    selectedFilter.value = 'category';

    if (categoryIds.isEmpty) {
      // Nếu không chọn danh mục, quay lại danh sách khóa học mặc định
      _loadFilteredCourses();
      return;
    }

    // Sử dụng tất cả các danh mục đã chọn
    _loadCoursesByCategories(categoryIds);
  }

  Future<void> _loadCoursesByCategories(List<int> categoryIds) async {
    isLoading.value = true;
    try {
      // Sử dụng API phân trang với categoryIds
      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: 'category',
        categoryIds: categoryIds,
        page: currentPage.value - 1,
        size: itemsPerPage,
        accountId: _accountId,
      );

      // Chỉ sử dụng kết quả từ API trả về
      filteredCourses.value = paginationResponse.content;
      totalPages.value = paginationResponse.totalPages;
      totalElements.value = paginationResponse.totalElements;

      print(
          'Đã tải ${paginationResponse.content.length} khóa học cho ${categoryIds.length} danh mục');
      print('Danh mục IDs: $categoryIds');
      print(
          'Tổng số: ${paginationResponse.totalElements} khóa học, ${paginationResponse.totalPages} trang');
    } catch (e) {
      print('Lỗi khi tải khóa học theo danh mục: $e');
      filteredCourses.value = [];
      totalPages.value = 1;
      totalElements.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > totalPages.value) return;

    currentPage.value = page;
    isLoading.value = true;

    try {
      String type = selectedFilter.value;
      // Nếu filter là "all" thì sử dụng "popular"
      if (type == 'all') {
        type = 'popular';
      }

      List<int>? categoryIds;

      switch (selectedFilter.value) {
        case 'category':
          if (selectedCategoryIds.value.isNotEmpty) {
            categoryIds = selectedCategoryIds.value;
          }
          break;
        case 'discount':
          type = 'discount';
          break;
        case 'combo':
          type = 'combo';
          break;
      }

      print(
          'Chuyển trang $page với filter: $selectedFilter.value, type: $type');

      // Tải dữ liệu trang mới
      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: type,
        categoryIds: categoryIds,
        page: page - 1, // API bắt đầu từ 0
        size: itemsPerPage,
        accountId: _accountId,
      );

      // Cập nhật dữ liệu nhưng không thay đổi selectedFilter
      filteredCourses.value = paginationResponse.content;
      // Cập nhật tổng số trang và tổng số phần tử
      totalPages.value =
          paginationResponse.totalPages > 0 ? paginationResponse.totalPages : 1;
      totalElements.value = paginationResponse.totalElements;

      // Xử lý lọc giảm giá riêng cho trường hợp discount
      if (selectedFilter.value == 'discount') {
        _processDiscountFilters();
      }
    } catch (e) {
      print('Lỗi khi chuyển trang: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _processDiscountFilters() {
    // Xác định các khoảng giảm giá đã chọn
    final selectedRanges = discountRanges.value.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedRanges.isEmpty) {
      // Nếu không có khoảng giảm giá nào được chọn, hiển thị tất cả
      return;
    }

    // Lọc khóa học theo khoảng giảm giá đã chọn
    filteredCourses.value = filteredCourses.value.where((course) {
      final discount = course.getRealDiscountPercent();

      for (final range in selectedRanges) {
        if (range == '0-10%' && discount > 0 && discount <= 10) {
          return true;
        } else if (range == '10-30%' && discount > 10 && discount <= 30) {
          return true;
        } else if (range == '30-50%' && discount > 30 && discount <= 50) {
          return true;
        } else if (range == '50-70%' && discount > 50 && discount <= 70) {
          return true;
        } else if (range == '70%+' && discount > 70) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  List<CourseCardModel> getCurrentPageCourses() {
    return filteredCourses.value;
  }

  int getTotalPages() {
    return totalPages.value;
  }

  Future<void> _loadDiscountCourses() async {
    isLoading.value = true;
    try {
      // Sử dụng API phân trang với type=discount
      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: 'discount',
        page: currentPage.value - 1,
        size: itemsPerPage,
        accountId: _accountId,
      );

      filteredCourses.value = paginationResponse.content;
      totalPages.value = paginationResponse.totalPages;
      totalElements.value = paginationResponse.totalElements;

      _processDiscountFilters();
    } catch (e) {
      print('Lỗi khi tải khóa học giảm giá: $e');
      // Fallback cho phương thức cũ
      try {
        final discountCourses =
            await courseUseCase.getFilteredCourses(type: 'discount');
        filteredCourses.value = discountCourses;
      } catch (e) {
        print('Lỗi khi tải khóa học giảm giá (fallback): $e');
        filteredCourses.value = [];
      }
    } finally {
      isLoading.value = false;
    }
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

  // Phương thức tìm kiếm khóa học cập nhật để sử dụng API phân trang
  void searchCourses(String query) async {
    isLoading.value = true;
    try {
      currentPage.value = 1; // Reset về trang đầu tiên khi tìm kiếm

      final paginationResponse = await courseUseCase.getCoursesWithPagination(
        type: 'popular',
        search: query,
        page: 0,
        size: itemsPerPage,
        accountId: _accountId,
      );

      // Chỉ sử dụng kết quả từ API trả về, không lọc thêm
      filteredCourses.value = paginationResponse.content;
      totalPages.value = paginationResponse.totalPages;
      totalElements.value = paginationResponse.totalElements;

      print(
          'Tìm thấy ${paginationResponse.totalElements} khóa học với từ khóa "$query"');
    } catch (e) {
      print('Lỗi khi tìm kiếm khóa học: $e');
      filteredCourses.value = [];
      totalPages.value = 1;
      totalElements.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    filteredCourses.dispose();
    allCourses.dispose();
    currentPage.dispose();
    totalPages.dispose();
    totalElements.dispose();
    selectedFilter.dispose();
    categories.dispose();
    selectedCategoryIds.dispose();
    isLoading.dispose();
    discountRanges.dispose();
  }
}
