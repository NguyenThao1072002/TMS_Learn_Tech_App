import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course_card_model.dart';

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
          return _processApiResponse(response.data);
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

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return _processApiResponse(response.data);
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

  List<CourseCardModel> _processApiResponse(dynamic responseData) {
    try {
      if (responseData is! Map) {
        return [];
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(responseData);
      
      // Cấu trúc API dạng {status, message, data: [...]}
      if (data.containsKey('status') && data.containsKey('data')) {
        final apiData = data['data'];

        if (apiData is List) {

          if (apiData.isEmpty) {
            return [];
          }

          final courses =
              apiData.map((item) => CourseCardModel.fromJson(item)).toList();
          return courses;
        } else if (apiData is Map &&
            apiData.containsKey('content') &&
            apiData['content'] is List) {
          final contentList = apiData['content'] as List;

          if (contentList.isEmpty) {
            return [];
          }

          final courses = contentList
              .map((item) => CourseCardModel.fromJson(item))
              .toList();

          return courses;
        }
      }

      // Cấu trúc API trực tiếp là danh sách
      if (data.containsKey('content') && data['content'] is List) {
        final contentList = data['content'] as List;

        if (contentList.isEmpty) {
          return [];
        }

        final courses =
            contentList.map((item) => CourseCardModel.fromJson(item)).toList();

        return courses;
      }

      // Trường hợp data là mảng trực tiếp
      if (responseData is List) {
        final courses = (responseData as List)
            .map((item) => CourseCardModel.fromJson(item))
            .toList();

        return courses;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
