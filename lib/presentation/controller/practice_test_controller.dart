import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';

// Enum cho loại bộ lọc
enum FilterType {
  CATEGORY,
  LEVEL,
  AUTHOR,
  PRICE,
  DISCOUNT,
  EXAM_TYPE,
  COURSE,
  ALL
}

// Class gom nhóm các bộ lọc
class PracticeTestFilter {
  String? level;
  String? examType;
  double? minPrice;
  double? maxPrice;
  int? minDiscount;
  int? maxDiscount;
  int? courseId;
  int? categoryId;
  String? author;
  String? searchQuery;

  PracticeTestFilter({
    this.level,
    this.examType,
    this.minPrice,
    this.maxPrice,
    this.minDiscount,
    this.maxDiscount,
    this.courseId,
    this.categoryId,
    this.author,
    this.searchQuery,
  });

  // Clear một bộ lọc cụ thể
  void clear(FilterType type) {
    switch (type) {
      case FilterType.CATEGORY:
        categoryId = null;
        break;
      case FilterType.LEVEL:
        level = null;
        break;
      case FilterType.AUTHOR:
        author = null;
        break;
      case FilterType.PRICE:
        minPrice = null;
        maxPrice = null;
        break;
      case FilterType.DISCOUNT:
        minDiscount = null;
        maxDiscount = null;
        break;
      case FilterType.EXAM_TYPE:
        examType = null;
        break;
      case FilterType.COURSE:
        courseId = null;
        break;
      case FilterType.ALL:
        level = null;
        examType = null;
        minPrice = null;
        maxPrice = null;
        minDiscount = null;
        maxDiscount = null;
        courseId = null;
        categoryId = null;
        author = null;
        searchQuery = null;
        break;
    }
  }

  // Xóa tất cả các bộ lọc
  void clearAll() {
    clear(FilterType.ALL);
  }

  // Kiểm tra xem có bộ lọc nào được áp dụng không
  bool get hasFilters =>
      level != null ||
      examType != null ||
      minPrice != null ||
      maxPrice != null ||
      minDiscount != null ||
      maxDiscount != null ||
      courseId != null ||
      categoryId != null ||
      author != null ||
      searchQuery != null;
}

class PracticeTestController with ChangeNotifier {
  // Use the PracticeTestUseCase from GetIt
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();

  // State variables
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final List<PracticeTestCardModel> _tests = [];
  String _selectedCategory = 'Tất cả';
  List<Map<String, dynamic>> _categories = [];
  final List<String> _levelOptions = ['Tất cả', 'EASY', 'MEDIUM', 'HARD'];
  final List<String> _authorOptions = [];
  bool _isTopSectionExpanded = true;
  String _errorMessage = '';

  // Bộ lọc
  final PracticeTestFilter _filter = PracticeTestFilter();

  // Getters
  bool get isLoading => _isLoading;
  List<PracticeTestCardModel> get tests => _tests;
  bool get hasMore => _hasMore;
  String get selectedCategory => _selectedCategory;
  List<Map<String, dynamic>> get categories => _categories;
  List<String> get levelOptions => _levelOptions;
  List<String> get authorOptions => _authorOptions;
  bool get isTopSectionExpanded => _isTopSectionExpanded;
  String get errorMessage => _errorMessage;

  // Getters cho các bộ lọc
  String? get levelFilter => _filter.level;
  String? get examTypeFilter => _filter.examType;
  double? get minPriceFilter => _filter.minPrice;
  double? get maxPriceFilter => _filter.maxPrice;
  int? get minDiscountFilter => _filter.minDiscount;
  int? get maxDiscountFilter => _filter.maxDiscount;
  int? get courseIdFilter => _filter.courseId;
  int? get categoryIdFilter => _filter.categoryId;
  String? get authorFilter => _filter.author;
  String? get searchQuery => _filter.searchQuery;

  // Setter cho errorMessage
  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  PracticeTestController() {
    _initializeData();
  }

  // Khởi tạo dữ liệu ban đầu
  Future<void> _initializeData() async {
    await loadCategories();
    await loadTests();
  }

  void toggleTopSection() {
    _isTopSectionExpanded = !_isTopSectionExpanded;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _practiceTestUseCase.getPracticeTestCategories();
      _categories = categories;
      // Đã có tests, cập nhật authors
      if (_tests.isNotEmpty) {
        _extractAuthors();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _logError('Error loading categories', e, stackTrace);
      _categories = [];
      notifyListeners();
    }
  }

  void _extractAuthors() {
    final authorSet = <String>{};

    // Add default "All" option
    authorSet.add('Tất cả');

    // Extract unique authors from tests
    for (var test in _tests) {
      if (test.author.isNotEmpty) {
        authorSet.add(test.author);
      }
    }

    _authorOptions.clear();
    _authorOptions.addAll(authorSet.toList()..sort());
  }

  // Hàm ghi log lỗi
  void _logError(String message, dynamic error, StackTrace? stackTrace) {
    _errorMessage = '$message: $error';
    print('$message: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  Future<void> loadTests({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (refresh) {
      _resetPagination();
    }
    notifyListeners();

    try {
      final tests = await _practiceTestUseCase.getFilteredPracticeTests(
        title: _filter.searchQuery,
        courseId: _filter.courseId,
        categoryId: _filter.categoryId,
        level: _filter.level,
        examType: _filter.examType,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        minDiscount: _filter.minDiscount,
        maxDiscount: _filter.maxDiscount,
        author: _filter.author,
        page: _currentPage,
        size: _pageSize,
      );

      if (tests.isEmpty) {
        _hasMore = false;
      } else {
        _tests.addAll(tests);
        _currentPage++;

        // Cập nhật danh sách tác giả
        _extractAuthors();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logError('Error loading tests', e, stackTrace);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset lại phân trang
  void _resetPagination() {
    _currentPage = 0;
    _tests.clear();
    _hasMore = true;
  }

  // Áp dụng bộ lọc và tải lại dữ liệu
  void applyFilters() {
    _resetPagination();
    loadTests();
  }

  // Làm mới dữ liệu
  Future<void> refresh() async {
    _resetPagination();
    await loadTests();
  }

  // Cập nhật tìm kiếm
  void setSearchQuery(String? query) {
    _filter.searchQuery = query;
    _resetPagination();
    loadTests();
  }

  // Tìm kiếm chỉ theo tiêu đề và tác giả
  void search(String? query) {
    _resetPagination();
    _isLoading = true;
    notifyListeners();

    if (query == null || query.isEmpty) {
      // Nếu query rỗng, lấy tất cả đề thi
      _filter.searchQuery = null;
      loadTests().then((_) {
        _isLoading = false;
        notifyListeners();
      });
      return;
    }

    try {
      // Trước tiên, gọi API để lấy càng nhiều kết quả có thể
      _practiceTestUseCase
          .getPracticeTests(
        search: query,
        page: 0,
        size: 50, // Lấy nhiều kết quả hơn để có thể lọc
      )
          .then((results) {
        _tests.clear();

        if (results.isEmpty) {
          print("Không tìm thấy kết quả cho: $query");
          _isLoading = false;
          notifyListeners();
          return;
        }

        final queryLowerCase = query.toLowerCase();

        // Lọc và sắp xếp kết quả theo mức độ phù hợp
        final filteredTests = <PracticeTestCardModel>[];
        final titleMatches = <PracticeTestCardModel>[];
        final authorMatches = <PracticeTestCardModel>[];
        final partialMatches = <PracticeTestCardModel>[];

        for (var test in results) {
          final titleLower = test.title.toLowerCase();
          final authorLower = test.author.toLowerCase();

          // Tìm kiếm chính xác trong tiêu đề
          if (titleLower == queryLowerCase) {
            titleMatches.add(test);
          }
          // Tìm kiếm chính xác trong tác giả
          else if (authorLower == queryLowerCase) {
            authorMatches.add(test);
          }
          // Tìm kiếm một phần trong tiêu đề
          else if (titleLower.contains(queryLowerCase)) {
            titleMatches.add(test);
          }
          // Tìm kiếm một phần trong tác giả
          else if (authorLower.contains(queryLowerCase)) {
            authorMatches.add(test);
          }
          // Tìm kiếm một phần của từng từ trong query
          else {
            final queryWords = queryLowerCase.split(' ');
            bool hasMatch = false;

            for (var word in queryWords) {
              if (word.length > 2 &&
                  (titleLower.contains(word) || authorLower.contains(word))) {
                hasMatch = true;
                break;
              }
            }

            if (hasMatch) {
              partialMatches.add(test);
            }
          }
        }

        // Kết hợp các kết quả theo thứ tự ưu tiên
        filteredTests.addAll(titleMatches);
        filteredTests.addAll(authorMatches);
        filteredTests.addAll(partialMatches);

        // Loại bỏ các bản sao nếu có
        final uniqueTests = <PracticeTestCardModel>[];
        final testIds = <int>{};

        for (var test in filteredTests) {
          if (!testIds.contains(test.testId)) {
            uniqueTests.add(test);
            testIds.add(test.testId);
          }
        }

        print("Tìm thấy ${uniqueTests.length} kết quả cho: $query");
        _tests.addAll(uniqueTests);
        _currentPage = 1; // Đánh dấu là đã tìm xong trang đầu tiên
        _hasMore = false; // Không cần phân trang khi tìm kiếm
        _isLoading = false;
        notifyListeners();
      }).catchError((error) {
        print("Lỗi khi tìm kiếm: $error");
        _isLoading = false;
        notifyListeners();
      });
    } catch (e, stackTrace) {
      _logError('Error searching tests', e, stackTrace);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chọn danh mục
  void selectCategory(String categoryName, int? categoryId) {
    _selectedCategory = categoryName;
    _filter.categoryId = categoryId;
    _resetPagination();
    loadTests();
  }

  // Cập nhật bộ lọc
  void updateFilters({
    String? levelFilter,
    String? authorFilter,
    double? minPriceFilter,
    double? maxPriceFilter,
    int? categoryIdFilter,
    String? examTypeFilter,
    int? minDiscountFilter,
    int? maxDiscountFilter,
    int? courseIdFilter,
  }) {
    // Chỉ cập nhật các bộ lọc được cung cấp
    if (levelFilter != null) _filter.level = levelFilter;
    if (authorFilter != null) _filter.author = authorFilter;
    if (minPriceFilter != null) _filter.minPrice = minPriceFilter;
    if (maxPriceFilter != null) _filter.maxPrice = maxPriceFilter;
    if (categoryIdFilter != null) _filter.categoryId = categoryIdFilter;
    if (examTypeFilter != null) _filter.examType = examTypeFilter;
    if (minDiscountFilter != null) _filter.minDiscount = minDiscountFilter;
    if (maxDiscountFilter != null) _filter.maxDiscount = maxDiscountFilter;
    if (courseIdFilter != null) _filter.courseId = courseIdFilter;

    notifyListeners();
  }

  // Xóa bộ lọc
  void clearFilter(FilterType type) {
    _filter.clear(type);
    notifyListeners();
    applyFilters();
  }

  // Xóa tất cả bộ lọc
  void clearAllFilters() {
    _filter.clearAll();
    _selectedCategory = 'Tất cả';
    notifyListeners();
    applyFilters();
  }

  // Các hàm trợ giúp
  String getCategoryName(int categoryId) {
    try {
      final category = _categories.firstWhere(
        (category) => category['id'] == categoryId,
        orElse: () => {'name': 'Unknown'},
      );

      final name = category['name'];
      if (name == null) {
        _logError(
            'Warning: Category $categoryId has null name', category, null);
        return 'Unknown';
      }

      return name.toString();
    } catch (e) {
      _logError('Error getting category name for ID $categoryId', e, null);
      return 'Unknown';
    }
  }

  // Để các hàm tiện ích vẫn có thể sử dụng trong controller
  String translateLevel(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class PracticeTestDetailController with ChangeNotifier {
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();

  PracticeTestDetailModel? _testDetail;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  PracticeTestDetailModel? get testDetail => _testDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PracticeTestDetailController(int testId) {
    loadTestDetail(testId);
  }

  Future<void> loadTestDetail(int testId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user ID if available
      int? accountId;
      // User account ID can be obtained from authentication provider when implemented

      final test = await _practiceTestUseCase.getPracticeTestDetail(
        testId,
        accountId: accountId,
      );

      if (test != null) {
        // Add default values if the API doesn't provide the new fields
        _testDetail = _addDefaultValuesIfNeeded(test);
      } else {
        _errorMessage = 'Không tìm thấy đề thi';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  PracticeTestDetailModel _addDefaultValuesIfNeeded(
      PracticeTestDetailModel test) {
    // If the API doesn't return any values for our new fields, provide some default ones
    List<String> testContents = test.testContents;
    List<String> knowledgeRequirements = test.knowledgeRequirements;

    // Add default values for testContents if empty
    if (testContents.isEmpty) {
      testContents = [
        'Kiến thức core và chuyên sâu về ${test.courseTitle}',
        'Kỹ năng xử lý vấn đề và debug code',
        'Hiểu biết về các best practices và design patterns',
        'Khả năng tối ưu hiệu suất ứng dụng',
      ];
    }

    // Add default values for knowledgeRequirements if empty
    if (knowledgeRequirements.isEmpty) {
      knowledgeRequirements = [
        'Kiến thức cơ bản về lập trình ${test.courseTitle}',
        'Đã từng phát triển ít nhất 1 ứng dụng di động',
        'Hiểu biết về UI/UX và component-based architecture',
      ];
    }

    // Only create a new instance if we've modified any of the fields
    if (testContents != test.testContents ||
        knowledgeRequirements != test.knowledgeRequirements) {
      return PracticeTestDetailModel(
        testId: test.testId,
        title: test.title,
        description: test.description,
        totalQuestion: test.totalQuestion,
        courseId: test.courseId,
        courseTitle: test.courseTitle,
        itemCountPrice: test.itemCountPrice,
        itemCountReview: test.itemCountReview,
        rating: test.rating,
        imageUrl: test.imageUrl,
        level: test.level,
        examType: test.examType,
        status: test.status,
        price: test.price,
        cost: test.cost,
        percentDiscount: test.percentDiscount,
        purchased: test.purchased,
        createdAt: test.createdAt,
        updatedAt: test.updatedAt,
        intro: test.intro,
        author: test.author,
        testContents: testContents,
        knowledgeRequirements: knowledgeRequirements,
      );
    }

    return test;
  }

  void startTest() {
    // Implement logic to start the test
    if (_testDetail == null) return;

    // Logic for starting the test will be implemented here
  }

  void purchaseTest() {
    // Implement logic to purchase the test
    if (_testDetail == null) return;

    // Logic for purchasing the test will be implemented here
  }

  String getVietnameseLevel(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  Color getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
