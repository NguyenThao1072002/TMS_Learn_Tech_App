import 'package:flutter/material.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';

// Class để gom nhóm các bộ lọc blog
class BlogFilter {
  String? searchQuery;
  String? categoryId;
  String? authorName;
  bool? featured;

  BlogFilter({
    this.searchQuery,
    this.categoryId,
    this.authorName,
    this.featured,
  });

  // Xóa tất cả bộ lọc
  void clearAll() {
    searchQuery = null;
    categoryId = null;
    authorName = null;
    featured = null;
  }

  // Kiểm tra xem có bộ lọc nào được áp dụng không
  bool get hasFilters =>
      searchQuery != null ||
      categoryId != null ||
      (authorName != null && authorName != 'Tất cả') ||
      featured != null;
}

class BlogController {
  final BlogUsecase blogUsecase;
  final CategoryUseCase categoryUseCase;
  final ValueNotifier<List<BlogCardModel>> allBlogs = ValueNotifier([]);
  final ValueNotifier<List<BlogCardModel>> filteredBlogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<List<BlogCategory>> categories = ValueNotifier([]);
  final ValueNotifier<List<String>> selectedCategoryIds = ValueNotifier([]);
  final ValueNotifier<String?> searchQuery = ValueNotifier(null);
  final ValueNotifier<String?> selectedAuthorName = ValueNotifier(null);
  final ValueNotifier<bool?> featuredFilter = ValueNotifier(null);
  final ValueNotifier<List<String>> authors = ValueNotifier(['Tất cả']);
  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
  final int itemsPerPage = 10;

  // Gom nhóm các bộ lọc
  final BlogFilter _filter = BlogFilter();

  BlogController({required this.blogUsecase, required this.categoryUseCase}) {
    _initializeData();
  }

  // Khởi tạo dữ liệu ban đầu
  Future<void> _initializeData() async {
    await Future.wait([
      loadCategories(),
      loadBlogs(),
    ]);
  }

  // Hàm ghi log lỗi chi tiết
  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    final errorDetail = stackTrace != null
        ? '$message: $error\nStack trace: $stackTrace'
        : '$message: $error';

    print(errorDetail);
    errorMessage.value = message;
  }

  // Làm mới dữ liệu
  Future<void> refresh() async {
    isRefreshing.value = true;

    try {
      await Future.wait([
        loadCategories(),
        loadBlogs(refresh: true),
      ]);
    } catch (e, stackTrace) {
      _logError('Không thể làm mới dữ liệu', e, stackTrace);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadBlogs({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final blogs = await blogUsecase.getFilteredBlogs(
        searchQuery: _filter.searchQuery ?? searchQuery.value,
        categoryId: selectedCategoryIds.value.isEmpty
            ? null
            : selectedCategoryIds.value.first,
        authorName: _filter.authorName == 'Tất cả'
            ? null
            : _filter.authorName ?? selectedAuthorName.value,
        featured: _filter.featured ?? featuredFilter.value,
      );

      // Sort blogs by creation date (newest first)
      blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      allBlogs.value = blogs;
      filteredBlogs.value = blogs;

      // Extract unique authors
      _extractUniqueAuthors(blogs);
    } catch (e, stackTrace) {
      _logError('Không thể tải danh sách bài viết', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Trích xuất danh sách tác giả duy nhất
  void _extractUniqueAuthors(List<BlogCardModel> blogs) {
    final uniqueAuthors = <String>{'Tất cả'};
    for (var blog in blogs) {
      if (blog.authorName.isNotEmpty) {
        uniqueAuthors.add(blog.authorName);
      }
    }
    authors.value = uniqueAuthors.toList()..sort();
  }

  Future<void> loadCategories() async {
    try {
      final blogCategories = await categoryUseCase.getBlogCategories();
      categories.value = blogCategories;
    } catch (e, stackTrace) {
      _logError('Không thể tải danh mục', e, stackTrace);
      categories.value = [];
    }
  }

  void filterByCategories(List<String> categoryIds) {
    selectedCategoryIds.value = categoryIds;
    _filter.categoryId = categoryIds.isEmpty ? null : categoryIds.first;
    applyFilters();
  }

  void filterByAuthor(String? authorName) {
    selectedAuthorName.value = authorName;
    _filter.authorName = authorName;
    applyFilters();
  }

  void filterByFeatured(bool? featured) {
    featuredFilter.value = featured;
    _filter.featured = featured;
    applyFilters();
  }

  void setSearchQuery(String? query) {
    searchQuery.value = query;
    _filter.searchQuery = query;
    applyFilters();
  }

  void applyFilters() {
    loadBlogs(refresh: true);
  }

  void resetFilters() {
    selectedCategoryIds.value = [];
    selectedAuthorName.value = 'Tất cả';
    featuredFilter.value = null;
    searchQuery.value = null;
    _filter.clearAll();
    applyFilters();
  }

  String getCategoryName(String categoryId) {
    try {
      final category = categories.value.firstWhere(
        (category) => category.id.toString() == categoryId,
        orElse: () => BlogCategory(
          id: 0,
          name: 'Không xác định',
          level: 0,
          type: 'BLOG',
          itemCount: 0,
          status: '',
          createdAt: '',
          updatedAt: '',
        ),
      );
      return category.name;
    } catch (e, stackTrace) {
      _logError('Lỗi khi lấy tên danh mục', e, stackTrace);
      return 'Không xác định';
    }
  }

  // Kiểm tra xem có bộ lọc nào được kích hoạt
  bool get hasActiveFilters => _filter.hasFilters;

  void dispose() {
    allBlogs.dispose();
    filteredBlogs.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    categories.dispose();
    selectedCategoryIds.dispose();
    searchQuery.dispose();
    selectedAuthorName.dispose();
    featuredFilter.dispose();
    authors.dispose();
    isRefreshing.dispose();
  }
}
