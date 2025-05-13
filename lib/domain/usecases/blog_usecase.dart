import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';
import 'dart:async';

class BlogUsecase {
  final BlogRepository blogRepository;

  BlogUsecase(this.blogRepository);

  Future<List<BlogCardModel>> getAllBlogs() async {
    return await blogRepository.getAllBlogs();
  }

  Future<List<BlogCardModel>> getPopularBlogs() async {
    return await blogRepository.getPopularBlogs();
  }

  Future<List<BlogCardModel>> getBlogsByCategory(String categoryId) async {
    return await blogRepository.getBlogsByCategory(categoryId);
  }

  Future<BlogCardModel?> getBlogById(String id) async {
    return await blogRepository.getBlogById(id);
  }

  Future<bool> incrementBlogView(String id) async {
    // Thực hiện việc tăng lượt xem trong một Zone riêng
    // để không ảnh hưởng đến UI thread
    try {
      // Tăng lượt xem không đồng bộ và không chờ kết quả để UI không bị chặn
      unawaited(_incrementViewCount(id));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Phương thức riêng để thực hiện việc tăng lượt xem trong background
  Future<bool> _incrementViewCount(String id) async {
    const maxAttempts = 3;
    const initialDelayMs = 300;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final success = await blogRepository.incrementBlogView(id);
        if (success) {
          return true;
        }

        if (attempt < maxAttempts - 1) {
          final delayMs = initialDelayMs * (1 << attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (e) {
        if (attempt < maxAttempts - 1) {
          final delayMs = initialDelayMs * (1 << attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    return false;
  }

  Future<List<BlogCardModel>> getRelatedBlogs(String categoryId,
      {String? currentBlogId, int page = 0, int size = 10}) async {
    return await blogRepository.getRelatedBlogs(categoryId,
        currentBlogId: currentBlogId, page: page, size: size);
  }

  // New methods for search and filtering
  Future<List<BlogCardModel>> getFilteredBlogs({
    String? searchQuery,
    String? categoryId,
    String? authorId,
    String? authorName,
    bool? featured,
    int page = 0,
    int size = 10,
  }) async {
    // Lấy tất cả blogs với bộ lọc cơ bản
    final blogs = await blogRepository.getAllBlogs();

    // Áp dụng bộ lọc trong bộ nhớ
    final filtered = blogs.where((blog) {
      // Lọc theo từ khóa tìm kiếm nếu có (tìm trong tiêu đề và nội dung)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!blog.title.toLowerCase().contains(query) &&
            !blog.content.toLowerCase().contains(query) &&
            !blog.sumary.toLowerCase().contains(query)) {
          return false;
        }
      }
      // Lọc theo danh mục nếu chỉ định
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          categoryId != "Tất cả" &&
          blog.cat_blog_id != categoryId) {
        return false;
      }

      // Lọc theo ID tác giả nếu chỉ định
      if (authorId != null &&
          authorId.isNotEmpty &&
          blog.authorId != authorId) {
        return false;
      }

      // Lọc theo tên tác giả nếu chỉ định
      if (authorName != null &&
          authorName.isNotEmpty &&
          authorName != "Tất cả" &&
          blog.authorName != authorName) {
        return false;
      }

      // Lọc theo trạng thái nổi bật nếu chỉ định
      if (featured != null && blog.featured != featured) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  // Get list of unique author names from available blogs
  Future<List<String>> getUniqueAuthors() async {
    final blogs = await blogRepository.getAllBlogs();

    // Extract unique author names
    final Set<String> uniqueAuthors = {};
    for (var blog in blogs) {
      if (blog.authorName.isNotEmpty) {
        uniqueAuthors.add(blog.authorName);
      }
    }

    // Convert to sorted list
    final authorList = uniqueAuthors.toList()..sort();
    return authorList;
  }

  // Get list of unique categories from available blogs
  Future<List<Map<String, String>>> getUniqueCategories() async {
    final blogs = await blogRepository.getAllBlogs();

    // Extract unique categories
    final Map<String, String> uniqueCategories = {};
    for (var blog in blogs) {
      if (blog.catergoryName.isNotEmpty && blog.cat_blog_id.isNotEmpty) {
        uniqueCategories[blog.cat_blog_id] = blog.catergoryName;
      }
    }

    // Convert to list of maps
    final categoryList = uniqueCategories.entries
        .map((e) => {"id": e.key, "name": e.value})
        .toList();

    return categoryList;
  }
}
