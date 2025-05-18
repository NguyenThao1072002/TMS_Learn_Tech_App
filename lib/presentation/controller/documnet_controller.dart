import 'package:flutter/material.dart';
import 'package:tms_app/data/models/categories/document_category.dart';
import 'package:tms_app/data/models/document/document_model.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';

import 'package:tms_app/domain/usecases/documents_usecase.dart';

class DocumentController {
  final DocumentUseCase documentUseCase;
  final CategoryUseCase? categoryUseCase;
  final ValueNotifier<List<DocumentModel>> filteredDocuments =
      ValueNotifier([]);
  final ValueNotifier<Map<String, int>> categoryIdMap = ValueNotifier({});
  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final ValueNotifier<String> selectedFilter = ValueNotifier('all');
  final ValueNotifier<List<DocumentCategory>> categories = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> searchQuery = ValueNotifier('');
  final ValueNotifier<List<DocumentModel>> relatedDocuments = ValueNotifier([]);
  final int itemsPerPage = 10;

  DocumentController(this.documentUseCase, {this.categoryUseCase});

  Future<void> loadDocuments() async {
    isLoading.value = true;
    try {
      final documents = await documentUseCase.getAllDocuments();
      filteredDocuments.value = documents;
    } catch (e) {
      print('Error loading documents: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức để tải tài liệu liên quan
  Future<void> loadRelatedDocuments(int categoryId) async {
    try {
      final documents = await documentUseCase.getRelatedDocuments(categoryId);
      relatedDocuments.value = documents;
      print('Đã tải ${documents.length} tài liệu liên quan từ danh mục $categoryId');
    } catch (e) {
      print('Lỗi khi tải tài liệu liên quan: $e');
      relatedDocuments.value = [];
    }
  }

  // Phương thức tải danh sách category
  Future<void> loadCategories() async {
    try {
      print(
          'CategoryUseCase: ${categoryUseCase != null ? "initialized" : "null"}');
      if (categoryUseCase == null) {
        print('Error: CategoryUseCase is not initialized');
        categories.value = [];
        return;
      }

      print('Starting to load categories...');
      final documentCategories = await categoryUseCase!.getDocumentCategories();

      if (documentCategories.isEmpty) {
        print('Warning: No categories returned from API');
      }

      // Lọc chỉ lấy các danh mục có type là "DOCUMENT"
      categories.value =
          documentCategories.where((cat) => cat.type == "DOCUMENT").toList();
      print('Loaded ${categories.value.length} document categories');
    } catch (e) {
      print('Error loading categories: $e');
      categories.value = [];
    }
  }

  // Phương thức để lấy tên danh mục
  List<String> getCategoryNames() {
    List<String> categoryNames = ['Tất cả'];
    categoryNames.addAll(categories.value.map((cat) => cat.name).toList());
    return categoryNames;
  }

  // Phương thức để lấy ID của danh mục từ tên
  int? getCategoryIdByName(String? categoryName) {
    if (categoryName == 'Tất cả') {
      return null;
    }

    for (var category in categories.value) {
      if (category.name == categoryName) {
        return category.id;
      }
    }

    return null;
  }

  // Phương thức để lọc tài liệu theo tên danh mục
  Future<void> filterByCategory(String categoryName) async {
    if (categoryName == 'Tất cả') {
      // Nếu chọn 'Tất cả', tải lại tài liệu phổ biến
      await loadPopularDocuments();
      return;
    }

    final categoryId = getCategoryIdByName(categoryName);
    if (categoryId != null) {
      await loadDocumentsByCategory(categoryId);
    } else {
      print('Không tìm thấy ID cho danh mục: $categoryName');
      // Nếu không tìm thấy ID, tải lại tài liệu phổ biến
      await loadPopularDocuments();
    }
  }

  Future<void> loadPopularDocuments() async {
    isLoading.value = true;
    try {
      final documents = await documentUseCase.getPopularDocuments();
      filteredDocuments.value = documents;
    } catch (e) {
      print('Error loading popular documents: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
    }
    if (categoryUseCase != null) {
      await loadCategories();
    }
  }

  Future<void> loadNewDocuments() async {
    isLoading.value = true;
    try {
      final documents = await documentUseCase.getNewDocuments();
      filteredDocuments.value = documents;
    } catch (e) {
      print('Error loading new documents: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
    }
    if (categoryUseCase != null) {
      await loadCategories();
    }
  }

  Future<void> loadDocumentsByCategory(int categoryId) async {
    isLoading.value = true;
    try {
      final documents =
          await documentUseCase.getDocumentsByCategory(categoryId);
      filteredDocuments.value = documents;
    } catch (e) {
      print('Error loading documents by category: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDocuments(String keyword) async {
    if (keyword.isEmpty) {
      loadDocuments();
      return;
    }

    searchQuery.value = keyword;
    isLoading.value = true;
    try {
      final documents = await documentUseCase.searchDocuments(keyword);
      filteredDocuments.value = documents;
    } catch (e) {
      print('Error searching documents: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
    }
    currentPage.value = 1; // Reset to first page when searching
  }

  Future<DocumentModel?> getDocumentDetail(int id) async {
    isLoading.value = true;
    try {
      final document = await documentUseCase.getDocumentDetail(id);
      
      // Nếu lấy được chi tiết tài liệu thành công, tải tài liệu liên quan
      if (document != null && document.categoryId != null) {
        await loadRelatedDocuments(document.categoryId!);
      }
      
      return document;
    } catch (e) {
      print('Error getting document detail: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> incrementView(int documentId) async {
    try {
      return await documentUseCase.incrementView(documentId);
    } catch (e) {
      print('Error incrementing view: $e');
      return false;
    }
  }

  Future<bool> incrementDownload(int documentId) async {
    try {
      return await documentUseCase.incrementDownload(documentId);
    } catch (e) {
      print('Error incrementing download: $e');
      return false;
    }
  }

  void filterDocumentsByFormat(String format) {
    selectedFilter.value = format;
    if (format == 'all') {
      // Reset filter, but maintain any search query
      if (searchQuery.value.isNotEmpty) {
        searchDocuments(searchQuery.value);
      } else {
        loadDocuments();
      }
    } else {
      // Filter by format (PDF, DOCX, PPTX, etc.)
      filteredDocuments.value = filteredDocuments.value
          .where((document) =>
              document.format.toLowerCase() == format.toLowerCase())
          .toList();
    }
    currentPage.value = 1; // Reset to first page when filtering
  }

  void changePage(int page) {
    if (page > 0 && page <= getTotalPages()) {
      currentPage.value = page;
    }
  }

  List<DocumentModel> getCurrentPageDocuments() {
    if (filteredDocuments.value.isEmpty) {
      return [];
    }

    final startIndex = (currentPage.value - 1) * itemsPerPage;
    if (startIndex >= filteredDocuments.value.length) {
      return [];
    }

    final endIndex = startIndex + itemsPerPage;
    return filteredDocuments.value.sublist(
      startIndex,
      endIndex > filteredDocuments.value.length
          ? filteredDocuments.value.length
          : endIndex,
    );
  }

  int getTotalPages() {
    return (filteredDocuments.value.length / itemsPerPage).ceil();
  }

  void sortDocumentsByViews({bool descending = true}) {
    filteredDocuments.value.sort((a, b) =>
        descending ? b.view.compareTo(a.view) : a.view.compareTo(b.view));
    filteredDocuments.value = [...filteredDocuments.value]; // Trigger UI update
  }

  // Add a new method for combined filtering
  void filterDocumentsByFormatAndCategory(
      String format, int? categoryId) async {
    isLoading.value = true;
    try {
      List<DocumentModel> documents = [];

      // First, get documents by category if needed
      if (categoryId != null) {
        documents = await documentUseCase.getDocumentsByCategory(categoryId);
      } else {
        // Otherwise, get current tab documents
        documents = filteredDocuments.value;
      }

      // Then filter by format if needed
      if (format != 'Tất cả') {
        documents = documents
            .where((document) =>
                document.format.toLowerCase() == format.toLowerCase())
            .toList();
      }

      filteredDocuments.value = documents;
    } catch (e) {
      print('Error filtering documents: $e');
      filteredDocuments.value = [];
    } finally {
      isLoading.value = false;
      currentPage.value = 1; // Reset to first page when filtering
    }
  }

  void sortDocumentsByDate({bool descending = true}) {
    filteredDocuments.value.sort((a, b) => descending
        ? DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt))
        : DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
    filteredDocuments.value = [...filteredDocuments.value]; // Trigger UI update
  }

  void dispose() {
    filteredDocuments.dispose();
    categories.dispose();
    currentPage.dispose();
    selectedFilter.dispose();
    isLoading.dispose();
    searchQuery.dispose();
    relatedDocuments.dispose();
  }
}
