import 'package:dio/dio.dart';
import 'dart:math';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  CourseService(this.dio);

  Future<List<CourseCardModel>> getAllCourses() async {
    try {
      return await getPopularCourses();
    } catch (e) {
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
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?type=discount';
      print('Đang gọi API lấy khóa học giảm giá: $endpoint');

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          print('===== RAW API RESPONSE =====');
          print('Response data type: ${response.data.runtimeType}');
          print('Response data: ${response.data}');

          final courses = ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);

          print('Số lượng khóa học giảm giá trả về từ API: ${courses.length}');

          // Phân loại theo mức giảm giá
          final below10 = courses
              .where((c) => (c.discountPercent > 0 && c.discountPercent <= 10))
              .toList();
          final from10to30 = courses
              .where((c) => (c.discountPercent > 10 && c.discountPercent <= 30))
              .toList();
          final from30to50 = courses
              .where((c) => (c.discountPercent > 30 && c.discountPercent <= 50))
              .toList();
          final from50to70 = courses
              .where((c) => (c.discountPercent > 50 && c.discountPercent <= 70))
              .toList();
          final above70 =
              courses.where((c) => (c.discountPercent > 70)).toList();
          final zero = courses.where((c) => c.discountPercent == 0).toList();

          print('Thống kê mức giảm giá:');
          print('- Không giảm giá (0%): ${zero.length} khóa học');
          print('- Giảm giá 0-10%: ${below10.length} khóa học');
          print('- Giảm giá 10-30%: ${from10to30.length} khóa học');
          print('- Giảm giá 30-50%: ${from30to50.length} khóa học');
          print('- Giảm giá 50-70%: ${from50to70.length} khóa học');
          print('- Giảm giá trên 70%: ${above70.length} khóa học');

          // Kiểm tra % giảm giá của từng khóa học
          print('===== DANH SÁCH KHÓA HỌC GIẢM GIÁ =====');
          for (var course in courses) {
            print(
                'ID: ${course.id}, Tiêu đề: ${course.title}, Giảm giá: ${course.discountPercent}%, Giá: ${course.price}, Giá gốc: ${course.cost}');
          }

          return courses;
        } else {
          print('Lỗi API (${response.statusCode}): ${response.data}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi Dio khi lấy khóa học giảm giá: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy khóa học giảm giá: $e');
      return [];
    }
  }

  Future<OverviewCourseModel?> getOverviewCourseDetail(int id) async {
    try {
      final endpoint = '$apiUrl/courses/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;

          Map<String, dynamic> courseData;

          if (responseData != null && responseData['data'] != null) {
            // Nếu API trả về cấu trúc {status, message, data}
            courseData = responseData['data'];
          } else if (responseData != null &&
              responseData is Map<String, dynamic>) {
            // Nếu API trả về đối tượng trực tiếp
            courseData = responseData;
          } else {
            return null;
          }

          return OverviewCourseModel.fromJson(courseData);
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

  Future<List<ReviewCourseModel>> getReviewCourse(int id) async {
    try {
      final endpoint = '$apiUrl/reviews/course/$id';

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
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
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
          return [];
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

  Future<List<CourseCardModel>> getRelatedCourse(int categoryId) async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?categoryId=$categoryId';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
              },
            ));

        if (response.statusCode == 200) {
          if (response.data is List) {
            return (response.data as List)
                .map((item) => CourseCardModel.fromJson(item))
                .toList();
          }

          return ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);
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

  // Future<String> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('jwt') ?? '';
  // }
}
