import 'package:flutter/material.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';
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

  final ValueNotifier<List<CourseCardModel>> comboCourses = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingComboCourses = ValueNotifier(false);
  final ValueNotifier<ComboCourseDetailModel?> selectedCombo =
      ValueNotifier(null);

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

  // Phương thức mới cho combo courses

  // Tải danh sách combo courses - phiên bản đơn giản
  Future<void> loadComboCourses() async {
    isLoadingComboCourses.value = true;
    try {
      final dynamic response =
          await courseUseCase.getComboCoursesWithPagination(
        accountId: _accountId,
        size: 20,
      );

      List<CourseCardModel> result = [];
      print('Response API combo: $response');

      // Trường hợp 1: Response đã là danh sách các CourseCardModel
      if (response != null &&
          response.content != null &&
          response.content is List) {
        print('Trường hợp 1: Response đã có sẵn danh sách CourseCardModel');
        if (response.content.isNotEmpty &&
            response.content.first is CourseCardModel) {
          result = List.from(response.content);
          print(
              'Đã tìm thấy ${result.length} combo courses từ response.content');
        }
      }

      // Nếu result vẫn trống, thử phân tích cấu trúc JSON
      if (result.isEmpty && response != null) {
        // Trường hợp 2: Cấu trúc API là {data: {content: [...]}}
        dynamic contentData;

        print('Trường hợp 2: Phân tích cấu trúc JSON');
        if (response is Map &&
            response['data'] != null &&
            response['data'] is Map) {
          var data = response['data'];
          if (data['content'] != null && data['content'] is List) {
            contentData = data['content'];
            print('Tìm thấy content trong response[data][content]');
          }
        } else if (response is Map &&
            response['content'] != null &&
            response['content'] is List) {
          contentData = response['content'];
          print('Tìm thấy content trong response[content]');
        }

        if (contentData != null) {
          print('Phân tích ${contentData.length} mục trong contentData');
          for (var combo in contentData) {
            if (combo is Map) {
              try {
                // Parse các trường dữ liệu
                double price = 0.0; // Giá đã giảm
                if (combo['price'] != null) {
                  price = _parseDoubleValue(combo['price']);
                }

                double cost = price; // Giá gốc
                if (combo['cost'] != null) {
                  cost = _parseDoubleValue(combo['cost']);
                }

                int id = _parseIntValue(combo['id']);
                String name = combo['name']?.toString() ?? '';
                String description = combo['description']?.toString() ?? '';

                int discount = _parseIntValue(combo['discount']);
                if (cost > price && discount == 0) {
                  discount = ((cost - price) / cost * 100).round();
                }

                // Format imageUrl nếu cần
                String imageUrl = combo['imageUrl']?.toString() ?? '';
                if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                  imageUrl = 'http://103.166.143.198:8080' +
                      (imageUrl.startsWith('/') ? '' : '/') +
                      imageUrl;
                }

                // Debug
                print(
                    'Đã parse: ID=$id, title=$name, price=$price, cost=$cost');

                // Tạo CourseCardModel
                CourseCardModel courseCard = CourseCardModel(
                  id: id,
                  title: name,
                  description: description,
                  imageUrl: imageUrl,
                  price: price,
                  cost: cost,
                  discountPercent: discount,
                  author: 'TMS Learn Tech',
                  courseOutput: '',
                  duration: 0,
                  language: 'Vietnamese',
                  status: true,
                  type: 'COMBO',
                  categoryName: '',
                );

                result.add(courseCard);
              } catch (e) {
                print('Error mapping combo course: $e');
              }
            }
          }
        }
      }

      // Cập nhật ValueNotifier
      if (result.isNotEmpty) {
        print('Cập nhật danh sách combo courses với ${result.length} mục');
        comboCourses.value = result;
      } else {
        print('CẢNH BÁO: Không tìm thấy combo course nào sau khi parse!');
      }

      print('Đã tải ${result.length} combo khóa học');
    } catch (e) {
      print('Lỗi khi tải combo khóa học: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : ""}');
      comboCourses.value = [];
    } finally {
      isLoadingComboCourses.value = false;
    }
  }

  // Helper methods for parsing
  double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Tìm kiếm combo courses
  Future<void> searchComboCourses(String query) async {
    isLoadingComboCourses.value = true;
    try {
      final result = await courseUseCase.searchComboCourses(query);
      comboCourses.value = result;
      print('Tìm thấy ${result.length} combo khóa học với từ khóa "$query"');
    } catch (e) {
      print('Lỗi khi tìm kiếm combo khóa học: $e');
      comboCourses.value = [];
    } finally {
      isLoadingComboCourses.value = false;
    }
  }

  // Lấy chi tiết một combo course
  Future<ComboCourseDetailModel?> getComboDetail(int comboId) async {
    isLoadingComboCourses.value = true;
    try {
      final combo = await courseUseCase.getComboDetail(comboId);
      if (combo != null) {
        selectedCombo.value = combo;
        return combo;
      }
    } catch (e) {
      print('Lỗi khi lấy chi tiết combo khóa học: $e');
    } finally {
      isLoadingComboCourses.value = false;
    }
    return null;
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

    comboCourses.dispose();
    isLoadingComboCourses.dispose();
    selectedCombo.dispose();
  }
}
