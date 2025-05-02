import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course_card_model.dart';

class CourseService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  CourseService(this.dio);

  Future<List<CourseCardModel>> getAllCourses() async {
    try {
      print('🔍 CourseService - getAllCourses - API URL: $apiUrl');
      return await getPopularCourses();
    } catch (e) {
      print('❌ CourseService - Lỗi getAllCourses: $e');
      return [];
    }
  }

  Future<List<CourseCardModel>> getPopularCourses() async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?type=popular';
      print('🔍 CourseService - getPopularCourses - endpoint: $endpoint');

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        print('📊 API Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          return _processApiResponse(response.data);
        } else {
          print('⚠️ API trả về lỗi: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('❌ Lỗi kết nối Dio: ${e.type}');
        print('❌ Thông báo: ${e.message}');
        print('❌ Chi tiết: ${e.error}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi không xác định: $e');
      return [];
    }
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    try {
      final courses = await getPopularCourses();
      return courses.where((course) => course.discountPercent > 0).toList();
    } catch (e) {
      print('❌ Lỗi getDiscountCourses: $e');
      return [];
    }
  }

  List<CourseCardModel> _processApiResponse(dynamic responseData) {
    try {
      print('📦 Kiểm tra dữ liệu API');

      if (responseData is! Map) {
        print('⚠️ Dữ liệu không phải là Map: ${responseData.runtimeType}');
        return [];
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(responseData);
      print('🔑 API keys: ${data.keys.toList()}');

      // Cấu trúc API dạng {status, message, data: [...]}
      if (data.containsKey('status') && data.containsKey('data')) {
        print('📝 API chuẩn');
        final apiData = data['data'];

        if (apiData is List) {
          print('📝 API data là List có ${apiData.length} phần tử');

          if (apiData.isEmpty) {
            print('⚠️ Danh sách trống');
            return [];
          }

          final courses =
              apiData.map((item) => CourseCardModel.fromJson(item)).toList();

          print('✅ Đã parse ${courses.length} khóa học');
          return courses;
        } else if (apiData is Map &&
            apiData.containsKey('content') &&
            apiData['content'] is List) {
          final contentList = apiData['content'] as List;

          if (contentList.isEmpty) {
            print('⚠️ Danh sách content trống');
            return [];
          }

          final courses = contentList
              .map((item) => CourseCardModel.fromJson(item))
              .toList();

          print('✅ Đã parse ${courses.length} khóa học từ content');
          return courses;
        }
      }

      // Cấu trúc API trực tiếp là danh sách
      if (data.containsKey('content') && data['content'] is List) {
        final contentList = data['content'] as List;

        if (contentList.isEmpty) {
          print('⚠️ Danh sách trống');
          return [];
        }

        final courses =
            contentList.map((item) => CourseCardModel.fromJson(item)).toList();

        print('✅ Đã parse ${courses.length} khóa học');
        return courses;
      }

      // Trường hợp data là mảng trực tiếp
      if (responseData is List) {
        print('📝 API trả về List trực tiếp');
        final courses = (responseData as List)
            .map((item) => CourseCardModel.fromJson(item))
            .toList();

        print('✅ Đã parse ${courses.length} khóa học từ list');
        return courses;
      }

      print('⚠️ Không thể nhận dạng cấu trúc API, trả về danh sách trống');
      return [];
    } catch (e) {
      print('❌ Lỗi khi phân tích dữ liệu: $e');
      return [];
    }
  }
}
