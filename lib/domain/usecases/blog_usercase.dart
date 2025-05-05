
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
}