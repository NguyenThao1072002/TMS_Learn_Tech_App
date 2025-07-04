import 'package:flutter/material.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_list.dart';

enum SearchType {
  all,
  course,
  document,
  blog,
  practiceTest,
}

class UnifiedSearchDelegate extends SearchDelegate<String> {
  final Function(String, SearchType) onSearch;
  final SearchType searchType;
  final Widget Function(BuildContext, dynamic, SearchType) itemBuilder;
  final UnifiedSearchController searchController;

  // Các tiêu đề gợi ý mặc định cho mỗi loại tìm kiếm
  final Map<SearchType, String> _searchHints = {
    SearchType.all: 'Tìm kiếm tất cả...',
    SearchType.course: 'Tìm kiếm khóa học, tên giảng viên...',
    SearchType.document: 'Tìm kiếm tên tài liệu...',
    SearchType.blog: 'Tìm kiếm bài viết, tác giả...',
    SearchType.practiceTest: 'Tìm kiếm đề thi, tác giả...',
  };

  // Các mô tả cho mỗi loại tìm kiếm
  final Map<SearchType, String> _searchDescriptions = {
    SearchType.all: 'Tìm kiếm trong tất cả nội dung',
    SearchType.course: 'Tìm kiếm theo tên khóa học và tên giảng viên',
    SearchType.document: 'Tìm kiếm theo tên tài liệu',
    SearchType.blog: 'Tìm kiếm theo tiêu đề bài viết và tác giả',
    SearchType.practiceTest: 'Tìm kiếm theo tên đề thi và tác giả',
  };

  // Map các tiêu đề màn hình "Xem tất cả"
  final Map<SearchType, String> _viewAllTitles = {
    SearchType.all: 'Tất cả kết quả',
    SearchType.course: 'Khóa học',
    SearchType.document: 'Tài liệu',
    SearchType.blog: 'Bài viết',
    SearchType.practiceTest: 'Đề thi',
  };

  // Các gợi ý mặc định cho từng loại tìm kiếm
  final Map<SearchType, List<String>> _defaultSuggestions = {
    SearchType.all: [],
    SearchType.course: [],
    SearchType.document: [],
    SearchType.blog: [],
    SearchType.practiceTest: [],
  };

  // Biến đánh dấu trạng thái tìm kiếm và thời gian debounce
  bool _isSearching = false;
  DateTime? _lastSearchTime;

  UnifiedSearchDelegate({
    required this.onSearch,
    required this.searchType,
    required this.itemBuilder,
    required this.searchController,
  });

  @override
  String get searchFieldLabel => _searchHints[searchType] ?? 'Tìm kiếm...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
        color: Color(0xFF333333),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF3498DB)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _performSearch();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // Debounce tìm kiếm - chỉ tìm sau một khoảng thời gian không gõ
  void _performSearch() {
    final now = DateTime.now();
    _lastSearchTime = now;

    // Đánh dấu đang tìm kiếm
    _isSearching = true;

    // Thực hiện tìm kiếm sau 300ms nếu không có thêm ký tự nào được gõ
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_lastSearchTime == now) {
        // Gọi callback tìm kiếm với loại tìm kiếm tương ứng
        onSearch(query, searchType);
        _isSearching = false;
      }
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      _performSearch();
    }
    // Hiển thị kết quả tìm kiếm trực tiếp trên màn hình tìm kiếm
    return _buildSearchResultsWidget(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Nếu đang nhập và chưa bắt đầu tìm kiếm, hiển thị gợi ý
    // Nếu đã tìm kiếm, hiển thị kết quả
    if (query.isEmpty) {
      return _buildSuggestionsWidget(context);
    } else {
      // Thực hiện tìm kiếm thời gian thực khi người dùng gõ
      _performSearch();
      return _buildSearchResultsWidget(context);
    }
  }

  Widget _buildSuggestionsWidget(BuildContext context) {
    final suggestions = _defaultSuggestions[searchType] ?? [];

    // Nếu không có gợi ý, hiển thị giao diện đơn giản
    if (suggestions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _searchHints[searchType] ?? 'Tìm kiếm...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchDescriptions[searchType] ?? 'Nhập để tìm kiếm',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gợi ý tìm kiếm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchDescriptions[searchType] ?? 'Tìm kiếm...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.search,
                        color: Color(0xFF3498DB),
                      ),
                      title: Text(
                        suggestions[index],
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        query = suggestions[index];
                        _performSearch();
                        showResults(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Điều hướng đến màn hình "Xem tất cả"
  void _navigateToViewAll(BuildContext context) {
    // Không điều hướng đến màn hình khác nữa, thay vào đó hiển thị tất cả kết quả ngay trên màn hình tìm kiếm hiện tại
    showResults(context);
  }

  Widget _buildSearchResultsWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: searchController,
      builder: (context, child) {
        // Lấy kết quả đầy đủ từ controller theo loại tìm kiếm
        List<dynamic> results;
        switch (searchType) {
          case SearchType.all:
            results = searchController.fullAllResults;
            break;
          case SearchType.course:
            results = searchController.fullCourseResults;
            break;
          case SearchType.document:
            results = searchController.fullDocumentResults;
            break;
          case SearchType.blog:
            results = searchController.fullBlogResults;
            break;
          case SearchType.practiceTest:
            results = searchController.fullPracticeTestResults;
            break;
          default:
            print('Không tìm thấy loại tìm kiếm phù hợp, hiển thị kết quả trống');
            results = [];
        }

        // In log để kiểm tra kết quả tìm kiếm
        print('[SearchDelegate] Xây dựng lại kết quả: ${results.length} tài liệu');

        return Scaffold(
          backgroundColor: Colors.white,
          body: searchController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                  ),
                )
              : results.isEmpty
                  ? _buildEmptyResults(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return itemBuilder(context, results[index], searchType);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchDescriptions[searchType] ?? 'Tìm kiếm...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
