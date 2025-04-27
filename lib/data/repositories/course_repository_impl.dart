import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/data/services/course_service.dart';
import 'package:tms_app/domain/repositories/course_repository.dart'; 

class CourseRepositoryImpl implements CourseRepository {
  final CourseService courseService;
  
  CourseRepositoryImpl({required this.courseService});

  @override
  Future<List<CourseCardModel>> getAllCourses() async {
    return await courseService.getAllCourses();
  }

  Future<List<CourseCardModel>> getPopularCourses() async {
    return await courseService.getPopularCourses();
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    return await courseService.getDiscountCourses();
  }
}
