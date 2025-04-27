import 'package:tms_app/data/models/course_card_model.dart';

// chỉ cần khai báo phương thức
abstract class CourseRepository {
  Future<List<CourseCardModel>> getAllCourses(); 
  Future<List<CourseCardModel>> getPopularCourses(); 
  Future<List<CourseCardModel>> getDiscountCourses(); 
}

