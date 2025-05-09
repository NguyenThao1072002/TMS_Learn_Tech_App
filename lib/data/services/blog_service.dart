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

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final blogs = ApiResponseHelper.processList(
              response.data, BlogCardModel.fromJson);

          return blogs;
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
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
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
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
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<BlogCardModel?> getBlogById(String id) async {
    try {
      final endpoint = '$baseUrl/blogs/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          if (response.data is Map &&
              response.data.containsKey('status') &&
              response.data.containsKey('data')) {
            final blogData = response.data['data'];
            return BlogCardModel.fromJson(blogData);
          } else {
            return null;
          }
        } else {
          return null;
        }
      } on DioException catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Tăng số lượt xem cho bài viết
  Future<bool> incrementBlogView(String blogId) async {
    try {
      final endpoint = '$baseUrl/blogs/$blogId/view';

      try {
        final response = await dio.post(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        return response.statusCode == 200;
      } on DioException catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<BlogCardModel>> getRelatedBlogs(String categoryId,
      {String? currentBlogId, int page = 0, int size = 10}) async {
    try {
      final endpoint =
          '$baseUrl/blogs/public?categoryId=$categoryId&page=$page&size=$size';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final blogs = ApiResponseHelper.processList(
              response.data, BlogCardModel.fromJson);

          // Loại bỏ bài viết hiện tại khỏi danh sách bài viết liên quan
          if (currentBlogId != null) {
            return blogs.where((blog) => blog.id != currentBlogId).toList();
          }

          return blogs;
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
