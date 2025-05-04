

import 'package:tms_app/data/models/blog_card_model.dart';
import 'package:tms_app/data/services/blog_service.dart';
import 'package:tms_app/domain/repositories/blog_repository.dart';

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
}