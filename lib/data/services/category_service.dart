import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/category_model.dart';
import 'package:get_it/get_it.dart';

class CategoryService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  CategoryService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/categories/level3/course',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['data'] != null) {
          final List<dynamic> categoryData = responseData['data'];

          // Tạo danh sách categories từ dữ liệu JSON
          final categories =
              categoryData.map((json) => CategoryModel.fromJson(json)).toList();
          return categories;
        } else {
          throw Exception(
              'Failed to load categories: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}
