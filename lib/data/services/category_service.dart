import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/categories/course_category.dart';
import 'package:tms_app/data/models/categories/document_category.dart';
import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';

class CategoryService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  CategoryService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  // Phương thức lấy danh mục khóa học
  Future<List<CourseCategory>> getCourseCategories() async {
    try {
      print(
          'Đang gọi API danh mục khóa học: $baseUrl/api/categories/level3/course');
      final response = await dio.get(
        '$baseUrl/api/categories/level3/course',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final categories = ApiResponseHelper.processList(
            response.data, CourseCategory.fromJson);
        print('Số lượng danh mục khóa học: ${categories.length}');

        // Trả về danh sách danh mục từ API
        return categories;
      } else {
        print('Lỗi khi lấy danh mục khóa học: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception khi lấy danh mục khóa học: $e');
      if (e is DioException) {
        print('DioError response: ${e.response?.data}');
        print('DioError message: ${e.message}');
      }
      return [];
    }
  }

  // Phương thức lấy danh mục tài liệu
  Future<List<DocumentCategory>> getDocumentCategories() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/categories/level3/document',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final categories = ApiResponseHelper.processList(
            response.data, DocumentCategory.fromJson);
        return categories;
      } else {
        print('Lỗi khi lấy danh mục tài liệu: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy danh mục tài liệu: $e');
      return [];
    }
  }

  // Phương thức lấy danh mục bài viết
  Future<List<BlogCategory>> getBlogCategories() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/categories/level3/blog',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final categories =
            ApiResponseHelper.processList(response.data, BlogCategory.fromJson);
        return categories;
      } else {
        print('Lỗi khi lấy danh mục bài viết: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy danh mục bài viết: $e');
      return [];
    }
  }

  // Phương thức chung để giảm code trùng lặp (tùy chọn)
  Future<List<T>> _getCategories<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    required String categoryType,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/categories/level3/$endpoint',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['data'] != null) {
          final List<dynamic> categoryData = responseData['data'];
          final categories =
              categoryData.map((json) => fromJson(json)).toList();
          return categories;
        } else {
          throw Exception(
              'Failed to load $categoryType categories: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load $categoryType categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh mục $categoryType: $e');
      return [];
    }
  }
}
