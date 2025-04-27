import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';

class CourseUseCase {
  final CourseRepository courseRepository;

  CourseUseCase(this.courseRepository);

  Future<List<CourseCardModel>> getAllCourses() async {
    return await courseRepository.getAllCourses();
  }

  Future<List<CourseCardModel>> getPopularCourses() async {
    return await courseRepository.getPopularCourses();
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    return await courseRepository.getDiscountCourses();
  }
}
