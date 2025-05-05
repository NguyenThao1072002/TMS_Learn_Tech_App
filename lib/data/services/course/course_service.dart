import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';

class CourseService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  CourseService(this.dio);

  Future<List<CourseCardModel>> getAllCourses() async {
    try {
      return await getPopularCourses();
    } catch (e) {
      print('Lỗi khi tải tất cả khóa học: $e');
      return [];
    }
  }

  Future<List<CourseCardModel>> getPopularCourses() async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?type=popular';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);
        } else {
          print('Lỗi API khóa học phổ biến: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải khóa học phổ biến: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải khóa học phổ biến: $e');
      return [];
    }
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?type=discount';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);
        } else {
          print('Lỗi API khóa học giảm giá: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải khóa học giảm giá: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải khóa học giảm giá: $e');
      return [];
    }
  }

  Future<OverviewCourseModel?> getOverviewCourseDetail(int id) async {
    try {
      final endpoint = '$apiUrl/api/courses/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData != null && responseData['data'] != null) {
            // Nếu API trả về cấu trúc {status, message, data}
            return OverviewCourseModel.fromJson(responseData['data']);
          } else if (responseData != null) {
            // Nếu API trả về đối tượng trực tiếp
            return OverviewCourseModel.fromJson(responseData);
          }
          return null;
        } else {
          print('Lỗi API tổng quan chi tiết khoá học: ${response.statusCode}');
          return null;
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải tổng quan chi tiết khoá học: $e');
        return null;
      }
    } catch (e) {
      print('Lỗi chung khi tải tổng quan chi tiết khoá học: $e');
      return null;
    }
  }

  Future<List<ReviewCourseModel>> getReviewCourse(int id) async {
    try {
      final endpoint = '$apiUrl/api/reviews/course/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData != null && responseData['data'] != null) {
            final paginationResponse =
                ReviewPaginationResponse.fromJson(responseData['data']);
            return paginationResponse.content;
          }
          return [];
        } else {
          print('Lỗi API đánh giá khoá học: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải đánh giá khoá học: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải đánh giá khoá học: $e');
      return [];
    }
  }

  Future<List<StructureCourseModel>> getStructureCourse(int id) async {
    try {
      final endpoint = '$apiUrl/courses/$id/lessons-view';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData != null && responseData is List) {
            // API trả về danh sách các chương
            return responseData
                .map((item) => StructureCourseModel.fromJson(item))
                .toList();
          } else if (responseData != null &&
              responseData['data'] != null &&
              responseData['data'] is List) {
            // Nếu API trả về cấu trúc {status, message, data} và data là một mảng
            return (responseData['data'] as List)
                .map((item) => StructureCourseModel.fromJson(item))
                .toList();
          }
          // Trả về một danh sách rỗng nếu không có dữ liệu
          return [];
        } else {
          print('Lỗi API cấu trúc khoá học: ${response.statusCode}');
          // Trả về một danh sách rỗng nếu có lỗi
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải cấu trúc khoá học: $e');
        // Trả về một danh sách rỗng nếu có lỗi
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải cấu trúc khoá học: $e');
      // Trả về một danh sách rỗng nếu có lỗi
      return [];
    }
  }

  Future<List<OverviewCourseModel>> getRelatedCourse(int categoryId) async {
    try {
      final endpoint =
          '$apiUrl/api/courses/public/filter?categoryId=$categoryId';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, OverviewCourseModel.fromJson);
        } else {
          print('Lỗi API khoá học liên quan: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi dio khi tải khoá học liên quan: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi chung khi tải khoá học liên quan: $e');
      return [];
    }
  }
}
