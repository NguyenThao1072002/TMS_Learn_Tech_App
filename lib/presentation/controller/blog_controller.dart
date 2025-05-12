import 'package:flutter/material.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/domain/usecases/blog_usercase.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';

class BlogController {
  final BlogUsercase blogUsecase;
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
  final int itemsPerPage = 10;

  BlogController({required this.blogUsecase, required this.categoryUseCase});

  Future<void> loadBlogs({bool refresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final blogs = await blogUsecase.getFilteredBlogs(
        searchQuery: searchQuery.value,
        categoryId: selectedCategoryIds.value.isEmpty
            ? null
            : selectedCategoryIds.value.first,
        authorName: selectedAuthorName.value == 'Tất cả'
            ? null
            : selectedAuthorName.value,
        featured: featuredFilter.value,
      );

      // Sort blogs by creation date (newest first)
      blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      allBlogs.value = blogs;
      filteredBlogs.value = blogs;

      // Extract unique authors
      final uniqueAuthors = <String>{'Tất cả'};
      for (var blog in blogs) {
        if (blog.authorName.isNotEmpty) {
          uniqueAuthors.add(blog.authorName);
        }
      }
      authors.value = uniqueAuthors.toList()..sort();
    } catch (e) {
      errorMessage.value = 'Không thể tải danh sách bài viết: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final blogCategories = await categoryUseCase.getBlogCategories();
      categories.value = blogCategories;
    } catch (e) {
      errorMessage.value = 'Không thể tải danh mục: $e';
      categories.value = [];
    }
  }

  void filterByCategories(List<String> categoryIds) {
    selectedCategoryIds.value = categoryIds;
    applyFilters();
  }

  void filterByAuthor(String? authorName) {
    selectedAuthorName.value = authorName;
    applyFilters();
  }

  void filterByFeatured(bool? featured) {
    featuredFilter.value = featured;
    applyFilters();
  }

  void setSearchQuery(String? query) {
    searchQuery.value = query;
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
    } catch (e) {
      return 'Không xác định';
    }
  }

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
  }
}
