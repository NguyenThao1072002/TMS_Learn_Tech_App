import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/categories/document_category.dart';
import 'package:tms_app/data/services/category_service.dart';
import 'package:tms_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService categoryService;

  CategoryRepositoryImpl({required this.categoryService});

  @override
  Future<List<CourseCategory>> getCourseCategories() async {
    return await categoryService.getCourseCategories();
  }

  @override
  Future<List<BlogCategory>> getBlogCategories() async {
    return await categoryService.getBlogCategories();
  }

  @override
  Future<List<DocumentCategory>> getDocumentCategories() async {
    return await categoryService.getDocumentCategories();
  }
}
