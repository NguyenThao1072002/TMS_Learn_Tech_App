import 'package:tms_app/data/models/category_model.dart';
import 'package:tms_app/domain/repositories/category_repository.dart';

class CategoryUseCase {
  final CategoryRepository categoryRepository;

  CategoryUseCase(this.categoryRepository);

  Future<List<CategoryModel>> getCategories() async {
    return await categoryRepository.getCategories();
  }
}
