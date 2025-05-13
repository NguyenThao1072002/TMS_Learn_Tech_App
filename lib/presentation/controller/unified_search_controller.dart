import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';

class UnifiedSearchController with ChangeNotifier {
  // UseCases
  final CourseUseCase _courseUseCase = GetIt.instance<CourseUseCase>();
  final DocumentUseCase _documentUseCase = GetIt.instance<DocumentUseCase>();
  final BlogUsecase _blogUseCase = GetIt.instance<BlogUsecase>();
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';

  // Search results
  final List<dynamic> _courseResults = [];
  final List<dynamic> _documentResults = [];
  final List<dynamic> _blogResults = [];
  final List<dynamic> _practiceTestResults = [];
  final List<dynamic> _allResults = [];

  // Full search results (không giới hạn số lượng)
  final List<dynamic> _fullCourseResults = [];
  final List<dynamic> _fullDocumentResults = [];
  final List<dynamic> _fullBlogResults = [];
  final List<dynamic> _fullPracticeTestResults = [];
  final List<dynamic> _fullAllResults = [];

  // Thêm các biến mới để lưu kết quả đã giới hạn
  final List<dynamic> _limitedCourseResults = [];
  final List<dynamic> _limitedDocumentResults = [];
  final List<dynamic> _limitedBlogResults = [];
  final List<dynamic> _limitedPracticeTestResults = [];

  // Số lượng kết quả giới hạn trên mỗi trang tìm kiếm
  final int _searchPageLimit = 3;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Lấy kết quả giới hạn
  List<dynamic> get courseResults => _limitedCourseResults;
  List<dynamic> get documentResults => _limitedDocumentResults;
  List<dynamic> get blogResults => _limitedBlogResults;
  List<dynamic> get practiceTestResults => _limitedPracticeTestResults;
  List<dynamic> get allResults => _allResults;

  // Lấy kết quả đầy đủ
  List<dynamic> get fullCourseResults => _fullCourseResults;
  List<dynamic> get fullDocumentResults => _fullDocumentResults;
  List<dynamic> get fullBlogResults => _fullBlogResults;
  List<dynamic> get fullPracticeTestResults => _fullPracticeTestResults;
  List<dynamic> get fullAllResults => _fullAllResults;

  // Kiểm tra nếu có nhiều kết quả hơn giới hạn
  bool hasMoreCourseResults() => _courseResults.length > _searchPageLimit;
  bool hasMoreDocumentResults() => _documentResults.length > _searchPageLimit;
  bool hasMoreBlogResults() => _blogResults.length > _searchPageLimit;
  bool hasMorePracticeTestResults() =>
      _practiceTestResults.length > _searchPageLimit;
  bool hasMoreAllResults() => _allResults.length > _searchPageLimit;

  // Hàm giới hạn số lượng kết quả
  List<dynamic> _getLimitedResults(List<dynamic> results) {
    if (results.length <= _searchPageLimit) {
      print('results.length <= _searchPageLimit');
      return results;
    }
    return results.sublist(0, _searchPageLimit);
  }

  // Hàm chuyển đổi chuỗi tiếng Việt có dấu thành không dấu
  String _removeVietnameseAccents(String input) {
    final vietnamese =
        'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ';
    final latin =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    String result = input.toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], latin[i]);
    }

    return result;
  }

  // Tìm kiếm theo loại
  Future<void> search(String query, SearchType searchType) async {
    _isLoading = true;
    notifyListeners();

    try {
      switch (searchType) {
        case SearchType.all:
          await _searchAll(query);
          break;
        case SearchType.course:
          await _searchCourses(query);
          break;
        case SearchType.document:
          await _searchDocuments(query);
          break;
        case SearchType.blog:
          await _searchBlogs(query);
          break;
        case SearchType.practiceTest:
          await _searchPracticeTests(query);
          break;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm tất cả
  Future<void> _searchAll(String query) async {
    _allResults.clear();
    _fullAllResults.clear();

    await Future.wait([
      _searchCourses(query),
      _searchDocuments(query),
      _searchBlogs(query),
      _searchPracticeTests(query),
    ]);

    // Kết hợp tất cả kết quả đầy đủ (không giới hạn)
    _fullAllResults.addAll(_fullCourseResults);
    _fullAllResults.addAll(_fullDocumentResults);
    _fullAllResults.addAll(_fullBlogResults);
    _fullAllResults.addAll(_fullPracticeTestResults);

    // Kết hợp tất cả kết quả, nhưng áp dụng giới hạn cho mỗi loại trước khi kết hợp
    List<dynamic> limitedCourses = _getLimitedResults(_courseResults);
    List<dynamic> limitedDocuments = _getLimitedResults(_documentResults);
    List<dynamic> limitedBlogs = _getLimitedResults(_blogResults);
    List<dynamic> limitedPracticeTests =
        _getLimitedResults(_practiceTestResults);

    // Thêm kết quả có giới hạn vào danh sách kết quả tổng hợp
    _allResults.addAll(limitedCourses);
    _allResults.addAll(limitedDocuments);
    _allResults.addAll(limitedBlogs);
    _allResults.addAll(limitedPracticeTests);

    // Giới hạn lại tổng số kết quả nếu cần
    if (_allResults.length > _searchPageLimit) {
      final tempAllResults = List<dynamic>.from(_allResults);
      _allResults.clear();
      _allResults.addAll(tempAllResults.sublist(0, _searchPageLimit));
    }
  }

  // Tìm kiếm khóa học
  Future<void> _searchCourses(String query) async {
    _courseResults.clear();
    _fullCourseResults.clear();
    _limitedCourseResults.clear();

    try {
      // Sử dụng getAllCourses với tham số search
      final results = await _courseUseCase.getAllCourses(search: query);

      if (results.isNotEmpty) {
        _courseResults.addAll(results);
        _fullCourseResults.addAll(results);
        print(
            'UnifiedSearch: Tìm thấy ${results.length} khóa học với từ khóa "$query"');

        // Lưu kết quả giới hạn (tối đa 3)
        if (results.length <= _searchPageLimit) {
          _limitedCourseResults.addAll(results);
        } else {
          _limitedCourseResults.addAll(results.sublist(0, _searchPageLimit));
        }
      } else {
        print(
            'UnifiedSearch: Không tìm thấy khóa học nào với từ khóa "$query"');
      }
    } catch (e) {
      print('UnifiedSearch - Lỗi khi tìm kiếm khóa học: $e');

      // Fallback: thử lại mà không có tham số tìm kiếm
      try {
        final allCourses = await _courseUseCase.getAllCourses();

        if (query.isNotEmpty) {
          final queryNormalized = _removeVietnameseAccents(query.toLowerCase());

          for (var course in allCourses) {
            final titleNormalized =
                _removeVietnameseAccents(course.title.toLowerCase());
            final authorNormalized =
                _removeVietnameseAccents(course.author.toLowerCase());

            if (titleNormalized.contains(queryNormalized) ||
                authorNormalized.contains(queryNormalized)) {
              _courseResults.add(course);
              _fullCourseResults.add(course);
            }
          }
        } else {
          _courseResults.addAll(allCourses);
          _fullCourseResults.addAll(allCourses);
        }
      } catch (secondError) {
        print('UnifiedSearch - Lỗi khi lọc khóa học offline: $secondError');
      }
    }
  }

  // Tìm kiếm tài liệu
  Future<void> _searchDocuments(String query) async {
    _documentResults.clear();
    _fullDocumentResults.clear();

    // Gọi API
    final results = await _documentUseCase.searchDocuments(query);

    // Lọc thêm theo tên tài liệu
    if (query.isNotEmpty) {
      final queryNormalized = _removeVietnameseAccents(query.toLowerCase());

      for (var document in results) {
        final titleNormalized =
            _removeVietnameseAccents(document.title.toLowerCase());

        if (titleNormalized.contains(queryNormalized)) {
          _documentResults.add(document);
          _fullDocumentResults.add(document);
        }
      }
    } else {
      _documentResults.addAll(results);
      _fullDocumentResults.addAll(results);
    }
  }

  // Tìm kiếm blog
  Future<void> _searchBlogs(String query) async {
    _blogResults.clear();
    _fullBlogResults.clear();

    // Gọi API
    final results = await _blogUseCase.getAllBlogs();

    // Lọc thêm theo tiêu đề và tác giả
    if (query.isNotEmpty) {
      final queryNormalized = _removeVietnameseAccents(query.toLowerCase());

      for (var blog in results) {
        final titleNormalized =
            _removeVietnameseAccents(blog.title.toLowerCase());
        final authorNormalized =
            _removeVietnameseAccents(blog.authorName.toLowerCase());

        if (titleNormalized.contains(queryNormalized) ||
            authorNormalized.contains(queryNormalized)) {
          _blogResults.add(blog);
          _fullBlogResults.add(blog);
        }
      }
    } else {
      _blogResults.addAll(results);
      _fullBlogResults.addAll(results);
    }
  }

  // Tìm kiếm đề thi
  Future<void> _searchPracticeTests(String query) async {
    _practiceTestResults.clear();
    _fullPracticeTestResults.clear();

    // Gọi API
    final results = await _practiceTestUseCase.getPracticeTests(
      search: query,
      page: 0,
      size: 50, // Lấy nhiều kết quả hơn để đảm bảo đủ dữ liệu
    );

    // Lọc thêm theo tiêu đề và tác giả
    if (query.isNotEmpty) {
      final queryNormalized = _removeVietnameseAccents(query.toLowerCase());

      for (var test in results) {
        final titleNormalized =
            _removeVietnameseAccents(test.title.toLowerCase());
        final authorNormalized =
            _removeVietnameseAccents(test.author.toLowerCase());

        if (titleNormalized.contains(queryNormalized) ||
            authorNormalized.contains(queryNormalized)) {
          _practiceTestResults.add(test);
          _fullPracticeTestResults.add(test);
        }
      }
    } else {
      _practiceTestResults.addAll(results);
      _fullPracticeTestResults.addAll(results);
    }
  }

  // Xóa kết quả tìm kiếm
  void clearResults() {
    _courseResults.clear();
    _documentResults.clear();
    _blogResults.clear();
    _practiceTestResults.clear();
    _allResults.clear();

    _fullCourseResults.clear();
    _fullDocumentResults.clear();
    _fullBlogResults.clear();
    _fullPracticeTestResults.clear();
    _fullAllResults.clear();

    _limitedCourseResults.clear();
    _limitedDocumentResults.clear();
    _limitedBlogResults.clear();
    _limitedPracticeTestResults.clear();

    notifyListeners();
  }

  // Thêm phương thức để "Xem tất cả"
  void showAllCourseResults() {
    _limitedCourseResults.clear();
    _limitedCourseResults.addAll(_fullCourseResults);
    notifyListeners();
  }
}
