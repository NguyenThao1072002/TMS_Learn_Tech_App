import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/categories/document_category.dart';

abstract class CategoryRepository {
  Future<List<CourseCategory>> getCourseCategories();
  Future<List<BlogCategory>> getBlogCategories();
  Future<List<DocumentCategory>> getDocumentCategories();
}
