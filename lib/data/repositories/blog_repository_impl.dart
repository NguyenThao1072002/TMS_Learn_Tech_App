import '../../domain/repositories/blog_repository.dart';
import '../models/blog/blog_card_model.dart';
import '../services/blog_service.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogService blogService;

  BlogRepositoryImpl({required this.blogService});

  @override
  Future<List<BlogCardModel>> getAllBlogs() async {
    return await blogService.getAllBlogs();
  }

  @override
  Future<List<BlogCardModel>> getPopularBlogs() async {
    return await blogService.getPopularBlogs();
  }

  @override
  Future<List<BlogCardModel>> getBlogsByCategory(String categoryId) async {
    return await blogService.getBlogsByCategory(categoryId);
  }

  @override
  Future<BlogCardModel?> getBlogById(String id) async {
    return await blogService.getBlogById(id);
  }

  @override
  Future<bool> incrementBlogView(String id) async {
    return await blogService.incrementBlogView(id);
  }

  @override
  Future<List<BlogCardModel>> getRelatedBlogs(String categoryId,
      {String? currentBlogId, int page = 0, int size = 10}) async {
    return await blogService.getRelatedBlogs(categoryId,
        currentBlogId: currentBlogId, page: page, size: size);
  }
}
