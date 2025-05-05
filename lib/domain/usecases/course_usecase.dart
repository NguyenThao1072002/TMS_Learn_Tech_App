import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
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

  Future<OverviewCourseModel?> getOverviewCourseDetail(int id) async {
    return await courseRepository.getOverviewCourseDetail(id);
  }

  Future<List<StructureCourseModel>> getStructureCourse(int id) async {
    return await courseRepository.getStructureCourse(id);
  }

  Future<List<ReviewCourseModel>> getReviewCourse(int id) async {
    return await courseRepository.getReviewCourse(id);
  }

  Future<List<OverviewCourseModel>> getRelatedCourse(int categoryId) async {
    return await courseRepository.getRelatedCourse(categoryId);
  }
}
