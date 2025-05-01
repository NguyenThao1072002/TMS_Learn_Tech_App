import 'package:tms_app/data/models/category_model.dart';
import 'package:tms_app/data/services/category_service.dart';
import 'package:tms_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService categoryService;

  CategoryRepositoryImpl({required this.categoryService});

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await categoryService.getCategories();
  }
}
