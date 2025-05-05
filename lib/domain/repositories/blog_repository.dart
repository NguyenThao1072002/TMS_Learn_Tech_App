import 'package:tms_app/data/models/blog/blog_card_model.dart';

abstract class BlogRepository {
  Future<List<BlogCardModel>> getAllBlogs();
  Future<List<BlogCardModel>> getPopularBlogs();
  Future<List<BlogCardModel>> getBlogsByCategory(String categoryId);
  // Future<Blog> getBlogById(String id);
  // Future<void> createBlog(Blog blog);
  // Future<void> updateBlog(Blog blog);
  // Future<void> deleteBlog(String id);
  // Future<List<Blog>> searchBlogs(String query);
  // Future<List<Blog>> getBlogsByCategory(String categoryId);
  // Future<List<Blog>> getBlogsByAuthor(String authorId);
  // Future<List<Blog>> getBlogsByDate(DateTime date);
}
