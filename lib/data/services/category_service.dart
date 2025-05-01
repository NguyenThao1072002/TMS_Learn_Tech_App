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

        // Log toàn bộ response
        print('Category API Raw Response: ${response.data}');
        print('Category API Status Code: ${response.statusCode}');

        // Thêm log để kiểm tra dữ liệu từ API
        print('API Response data: $responseData');

        if (responseData['data'] != null) {
          final List<dynamic> categoryData = responseData['data'];

          // Log chi tiết dữ liệu
          print('Category data length: ${categoryData.length}');

          // Log dữ liệu chi tiết của category đầu tiên
          if (categoryData.isNotEmpty) {
            print('First category raw data: ${categoryData[0]}');
            print('First category name raw: ${categoryData[0]['name']}');
            print('First category JSON string: ${categoryData[0].toString()}');
          }

          // Tạo danh sách categories từ dữ liệu JSON
          final categories =
              categoryData.map((json) => CategoryModel.fromJson(json)).toList();

          // Log sau khi chuyển đổi thành model
          if (categories.isNotEmpty) {
            print(
                'First category after conversion - name: ${categories[0].name}');
            print('First category after conversion - id: ${categories[0].id}');
            print(
                'First category after conversion - itemCount: ${categories[0].itemCount}');
          }

          return categories;
        } else {
          print(
              'No category data found in response: ${responseData['message']}');
          throw Exception(
              'Failed to load categories: ${responseData['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.statusMessage}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback data
      return _getSampleCategories();
    }
  }

  // Sample data in case API fails
  List<CategoryModel> _getSampleCategories() {
    return [
      CategoryModel(
          id: 1,
          name: "Cyber Security",
          level: 3,
          type: "COURSE",
          description: "Khóa học về bảo mật thông tin",
          itemCount: 145,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 2,
          name: "Data Science",
          level: 3,
          type: "COURSE",
          description: "Khóa học về khoa học dữ liệu",
          itemCount: 120,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 3,
          name: "Cloud Computing",
          level: 3,
          type: "COURSE",
          description: "Khóa học về điện toán đám mây",
          itemCount: 100,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
      CategoryModel(
          id: 4,
          name: "Blockchain",
          level: 3,
          type: "COURSE",
          description: "Khóa học về blockchain",
          itemCount: 80,
          status: "ACTIVE",
          createdAt: "2025-03-18T22:02:27.889464",
          updatedAt: "2025-05-01T08:28:03.378102"),
    ];
  }
}
