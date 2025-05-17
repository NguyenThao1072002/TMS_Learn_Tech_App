import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:tms_app/data/services/course/course_service.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseService courseService;

  CourseRepositoryImpl({required this.courseService});

  @override
  Future<List<CourseCardModel>> getAllCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseService.getAllCourses(
      search: search,
      page: page,
      size: size,
      accountId: accountId,
    );
  }

  @override
  Future<List<CourseCardModel>> getPopularCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseService.getPopularCourses(
      search: search,
      page: page,
      size: size,
      accountId: accountId,
    );
  }

  @override
  Future<CoursePaginationResponse> getCoursesWithPagination({
    String type = 'popular',
    String? search,
    int? categoryId,
    List<int>? categoryIds,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseService.getCoursesWithPagination(
      type: type,
      search: search,
      categoryId: categoryId,
      categoryIds: categoryIds,
      page: page,
      size: size,
      accountId: accountId,
    );
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
    return await courseService.getReviewCourse(id);
  }

  @override
  Future<List<StructureCourseModel>> getStructureCourse(int id) async {
    return await courseService.getStructureCourse(id);
  }

  @override
  Future<List<CourseCardModel>> getRelatedCourse(int categoryId) async {
    return await courseService.getRelatedCourse(categoryId);
  }

  // Triển khai các phương thức cho combo courses

  @override
  Future<CoursePaginationResponse> getComboCoursesWithPagination({
    String? title,
    int? accountId,
    int page = 0,
    int size = 10,
  }) async {
    return await courseService.getComboCoursesWithPagination(
      title: title,
      accountId: accountId,
      page: page,
      size: size,
    );
  }

  @override
  Future<ComboCourseDetailModel?> getComboDetail(int id) async {
    return await courseService.getComboDetail(id);
  }

  @override
  Future<List<CourseCardModel>> searchComboCourses(String query) async {
    return await courseService.searchComboCourses(query);
  }
}
