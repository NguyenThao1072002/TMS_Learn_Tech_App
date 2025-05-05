import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';

class BlogService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  BlogService(this.dio);

  Future<List<BlogCardModel>> getAllBlogs() async {
    try {
      final endpoint = '$baseUrl/blogs/public?page=0&size=10';
      print('Gọi API: $endpoint');

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        print('API response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final blogs = ApiResponseHelper.processList(
              response.data, BlogCardModel.fromJson);
          print('Số lượng bài viết đã xử lý: ${blogs.length}');

          // Nếu không có bài viết nào từ API, trả về dữ liệu mẫu
          if (blogs.isEmpty) {
            print('Không có bài viết từ API, thử lại hoặc kiểm tra kết nối');
            return [];
          }

          return blogs;
        } else {
          print('Lỗi API ds bài viết: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải ds bài viết: $e');
        print('DioError response: ${e.response?.data}');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải ds bài viết: $e');
      print(
          'Error stack trace: ${e is Error ? e.stackTrace : "No stack trace"}');
      return [];
    }
  }

  Future<List<BlogCardModel>> getPopularBlogs() async {
    try {
      final endpoint = '$baseUrl/blogs/public?page=0&size=10';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, BlogCardModel.fromJson);
        } else {
          print('Lỗi API bài viết phổ biến: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải bài viết phổ biến: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải bài viết phổ biến: $e');
      return [];
    }
  }

  Future<List<BlogCardModel>> getBlogsByCategory(String categoryId) async {
    try {
      final endpoint = '$baseUrl/categories/level3/blog';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, BlogCardModel.fromJson);
        } else {
          print('Lỗi API bài viết theo danh mục: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải bài viết theo danh mục: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải bài viết theo danh mục: $e');
      return [];
    }
  }
}
