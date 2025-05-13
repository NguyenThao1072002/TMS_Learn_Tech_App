import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';

// chỉ cần khai báo phương thức
abstract class CourseRepository {
  Future<List<CourseCardModel>> getAllCourses({String? search});
  Future<List<CourseCardModel>> getPopularCourses({String? search});
  Future<List<CourseCardModel>> getDiscountCourses();
  Future<OverviewCourseModel?> getOverviewCourseDetail(int id);
  Future<List<ReviewCourseModel>> getReviewCourse(int id);
  Future<List<StructureCourseModel>> getStructureCourse(int id);
  Future<List<CourseCardModel>> getRelatedCourse(int categoryId);
}
