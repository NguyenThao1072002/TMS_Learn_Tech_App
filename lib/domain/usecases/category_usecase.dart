import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/categories/document_category.dart';
import 'package:tms_app/domain/repositories/category_repository.dart';

class CategoryUseCase {
  final CategoryRepository categoryRepository;

  CategoryUseCase(this.categoryRepository);

  Future<List<CourseCategory>> getCourseCategories() async {
    return await categoryRepository.getCourseCategories();
  }

  Future<List<BlogCategory>> getBlogCategories() async {
    return await categoryRepository.getBlogCategories();
  }

  Future<List<DocumentCategory>> getDocumentCategories() async {
    return await categoryRepository.getDocumentCategories();
  }
}
