import 'package:dio/dio.dart';
import 'package:tms_app/data/datasources/course_data.dart';
import 'package:tms_app/data/models/course_card_model.dart';

class CourseService {
  final String apiUrl = "https://yourapi.com/courses";
  final Dio dio;
  CourseService(this.dio);

  Future<List<CourseCardModel>> getAllCourses() async {
    try {
      return mockCourses; // Trả về danh sách khóa học giả lập
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  Future<List<CourseCardModel>> getPopularCourses() async {
    try {
      // Sắp xếp khóa học theo số lượng học viên giảm dần
      var sortedCourses = List<CourseCardModel>.from(mockCourses);
      sortedCourses
          .sort((a, b) => b.numberOfStudents.compareTo(a.numberOfStudents));

      return sortedCourses.take(5).toList();
    } catch (e) {
      throw Exception('Failed to load popular courses: $e');
    }
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    try {
      // Lọc các khóa học có giảm giá
      return mockCourses.where((course) => course.discountPercent > 0).toList();
    } catch (e) {
      throw Exception('Failed to load discount courses: $e');
    }
  }
}
