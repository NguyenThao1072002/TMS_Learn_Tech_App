import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';

class BlogUsercase {
  final BlogRepository blogRepository;

  BlogUsercase(this.blogRepository);

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
    return await blogRepository.incrementBlogView(id);
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
    // First get all blogs with basic filters
    final blogs = await blogRepository.getAllBlogs();

    // Apply filters in memory
    return blogs.where((blog) {
      // Filter by search query if provided (search in title and content)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!blog.title.toLowerCase().contains(query) &&
            !blog.content.toLowerCase().contains(query) &&
            !blog.sumary.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by category if specified
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          categoryId != "Tất cả" &&
          blog.cat_blog_id != categoryId) {
        return false;
      }

      // Filter by author ID if specified
      if (authorId != null &&
          authorId.isNotEmpty &&
          blog.authorId != authorId) {
        return false;
      }

      // Filter by author name if specified
      if (authorName != null &&
          authorName.isNotEmpty &&
          authorName != "Tất cả" &&
          blog.authorName != authorName) {
        return false;
      }

      // Filter by featured status if specified
      if (featured != null && blog.featured != featured) {
        return false;
      }

      return true;
    }).toList();
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
