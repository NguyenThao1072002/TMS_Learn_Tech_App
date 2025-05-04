import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/blog_card_model.dart';

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
          print('API response data: ${response.data}');
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

  // // Tạo một số bài viết mẫu để hiển thị khi không có dữ liệu từ API
  // List<BlogCardModel> _getSampleBlogs() {
  //   return [
  //     BlogCardModel(
  //       id: 1,
  //       title: 'Bài viết mẫu 1: Giới thiệu Flutter',
  //       content:
  //           '<p>Flutter là một framework phát triển ứng dụng di động đa nền tảng do Google phát triển.</p>',
  //       sumary:
  //           'Giới thiệu về framework Flutter và các tính năng chính của nó.',
  //       authorId: 1,
  //       createdAt: DateTime.now().subtract(const Duration(days: 5)),
  //       status: true,
  //       featured: true,
  //       cat_blog_id: 1,
  //       image:
  //           'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
  //       views: 256,
  //       commentCount: 12,
  //       catergoryName: 'Công nghệ',
  //       authorName: 'TMS Team',
  //       deleted: false,
  //     ),
  //     BlogCardModel(
  //       id: 2,
  //       title: 'Bài viết mẫu 2: Lập trình đa nền tảng',
  //       content:
  //           '<p>Các giải pháp phát triển ứng dụng đa nền tảng hiện đại.</p>',
  //       sumary:
  //           'So sánh các framework phát triển ứng dụng đa nền tảng phổ biến.',
  //       authorId: 2,
  //       createdAt: DateTime.now().subtract(const Duration(days: 10)),
  //       status: true,
  //       featured: false,
  //       cat_blog_id: 2,
  //       image:
  //           'https://miro.medium.com/v2/resize:fit:1400/1*ub_QbYoLWfKKXzA2NIQ6pA.png',
  //       views: 142,
  //       commentCount: 8,
  //       catergoryName: 'Lập trình',
  //       authorName: 'Tech Expert',
  //       deleted: false,
  //     ),
  //     BlogCardModel(
  //       id: 3,
  //       title: 'Bài viết mẫu 3: Trí tuệ nhân tạo (AI)',
  //       content:
  //           '<p>Ứng dụng trí tuệ nhân tạo trong phát triển phần mềm hiện đại.</p>',
  //       sumary: 'Tìm hiểu về cách AI đang thay đổi ngành phát triển phần mềm.',
  //       authorId: 3,
  //       createdAt: DateTime.now().subtract(const Duration(days: 3)),
  //       status: true,
  //       featured: true,
  //       cat_blog_id: 3,
  //       image:
  //           'https://www.researchgate.net/publication/333172573/figure/fig1/AS:760801282383881@1558408189604/Artificial-Intelligence-AI-refers-to-systems-designed-by-humans-that-given-a-complex.png',
  //       views: 325,
  //       commentCount: 18,
  //       catergoryName: 'Trí tuệ nhân tạo',
  //       authorName: 'AI Developer',
  //       deleted: false,
  //     ),
  //   ];
  // }

}
