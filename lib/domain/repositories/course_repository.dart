import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:tms_app/data/services/course/course_service.dart';

// chỉ cần khai báo phương thức
abstract class CourseRepository {
  Future<List<CourseCardModel>> getAllCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  });

  Future<List<CourseCardModel>> getPopularCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  });

  Future<CoursePaginationResponse> getCoursesWithPagination({
    String type = 'popular',
    String? search,
    int? categoryId,
    List<int>? categoryIds,
    int page = 0,
    int size = 10,
    int? accountId,
  });

  Future<List<CourseCardModel>> getDiscountCourses();
  Future<OverviewCourseModel?> getOverviewCourseDetail(int id);
  Future<List<ReviewCourseModel>> getReviewCourse(int id);
  Future<List<StructureCourseModel>> getStructureCourse(int id);
  Future<List<CourseCardModel>> getRelatedCourse(int categoryId);
}
