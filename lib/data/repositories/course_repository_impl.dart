import '../../domain/repositories/course_repository.dart';
import '../models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import '../models/course/course_detail/structure_course_model.dart';
import '../models/course/course_detail/review_course_model.dart';
import '../services/course/course_service.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseService courseService;

  CourseRepositoryImpl({required this.courseService});

  @override
  Future<List<CourseCardModel>> getAllCourses() async {
    return await courseService.getAllCourses();
  }

  @override
  Future<List<CourseCardModel>> getPopularCourses() async {
    return await courseService.getPopularCourses();
  }

  @override
  Future<List<CourseCardModel>> getDiscountCourses() async {
    return await courseService.getDiscountCourses();
  }

  @override
  Future<OverviewCourseModel?> getOverviewCourseDetail(int id) async {
    return await courseService.getOverviewCourseDetail(id);
  }

  @override
  Future<List<ReviewCourseModel>> getReviewCourse(int id) async {
    return courseService.getReviewCourse(id);
  }

  @override
  Future<List<StructureCourseModel>> getStructureCourse(int id) async {
    return await courseService.getStructureCourse(id);
  }

  @override
  Future<List<CourseCardModel>> getRelatedCourse(int categoryId) async {
    return await courseService.getRelatedCourse(categoryId);
  }
}
