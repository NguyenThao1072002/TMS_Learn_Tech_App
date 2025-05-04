import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';

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
}
