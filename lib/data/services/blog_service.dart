import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  BlogService(this.dio);

  Future<List<BlogCardModel>> getAllBlogs() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final endpoint = '$baseUrl/blogs/public?page=0&size=50&_t=$timestamp';

      final response = await dio.get(endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Accept': 'application/json',
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          ));

      if (response.statusCode == 200) {
        return ApiResponseHelper.processList(
            response.data, BlogCardModel.fromJson);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách blog: $e');
    }
  }

  Future<List<BlogCardModel>> getPopularBlogs() async {
    try {
      final endpoint = '$baseUrl/blogs/public?page=0&size=10';

      final response = await dio.get(endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ));

      if (response.statusCode == 200) {
        return ApiResponseHelper.processList(
            response.data, BlogCardModel.fromJson);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải blog phổ biến: $e');
    }
  }

  Future<List<BlogCardModel>> getBlogsByCategory(String categoryId) async {
    try {
      final endpoint = '$baseUrl/categories/level3/blog';

      final response = await dio.get(endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ));

      if (response.statusCode == 200) {
        return ApiResponseHelper.processList(
            response.data, BlogCardModel.fromJson);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải blog theo danh mục: $e');
    }
  }

  Future<BlogCardModel?> getBlogById(String id) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final endpoint = '$baseUrl/blogs/$id?_t=$timestamp';

      final response = await dio.get(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is Map &&
            response.data.containsKey('status') &&
            response.data.containsKey('data')) {
          final blogData = response.data['data'];
          return BlogCardModel.fromJson(blogData);
        } else {
          throw Exception('Dữ liệu API không đúng định dạng');
        }
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết blog: $e');
    }
  }

  // Tăng số lượt xem cho bài viết
  Future<bool> incrementBlogView(String blogId) async {
    try {
      final endpoint = '$baseUrl/blogs/$blogId/views';

      final response = await dio.put(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Không ném lỗi với tăng lượt xem, chỉ trả về false
      return false;
    }
  }

  Future<List<BlogCardModel>> getRelatedBlogs(String categoryId,
      {String? currentBlogId, int page = 0, int size = 10}) async {
    try {
      final endpoint =
          '$baseUrl/blogs/public?categoryId=$categoryId&page=$page&size=$size';

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
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải blog liên quan: $e');
    }
  }
}
