import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:tms_app/data/services/course/course_service.dart';
import 'package:tms_app/domain/repositories/course_repository.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';

class CourseUseCase {
  final CourseRepository courseRepository;

  CourseUseCase(this.courseRepository);

  Future<List<CourseCardModel>> getAllCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseRepository.getAllCourses(
      search: search,
      page: page,
      size: size,
      accountId: accountId,
    );
  }

  Future<List<CourseCardModel>> getPopularCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseRepository.getPopularCourses(
      search: search,
      page: page,
      size: size,
      accountId: accountId,
    );
  }

  Future<CoursePaginationResponse> getCoursesWithPagination({
    required String type,
    String? search,
    List<int>? categoryIds,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    return await courseRepository.getCoursesWithPagination(
      type: type,
      search: search,
      categoryIds: categoryIds,
      page: page,
      size: size,
      accountId: accountId,
    );
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    return await courseRepository.getDiscountCourses();
  }

  Future<List<CourseCardModel>> getFilteredCourses(
      {String type = '',
      int categoryId = 0,
      int? minDiscount,
      int? maxDiscount}) async {
    if (type == 'discount') {
      // Lấy tất cả khóa học giảm giá
      final courses = await courseRepository.getDiscountCourses();

      print(
          'USECASE: Lấy được ${courses.length} khóa học giảm giá từ repository');

      // Lọc chỉ lấy những khóa học có giảm giá > 0 hoặc có giá khác giá gốc
      final discountedCourses = courses
          .where((course) => course.getRealDiscountPercent() > 0)
          .toList();

      print(
          'USECASE: Sau khi lọc còn ${discountedCourses.length} khóa học thực sự giảm giá');

      // In ra thông tin chi tiết về các khóa học có giảm giá
      for (var course in discountedCourses) {
        print(
            'USECASE: Khóa học ID=${course.id}, Tên=${course.title}, Giảm=${course.getRealDiscountPercent()}%, DiscountPercent=${course.discountPercent}, Giá=${course.price}, Giá gốc=${course.cost}');
      }

      // Nếu có yêu cầu lọc theo phần trăm giảm giá
      if (minDiscount != null || maxDiscount != null) {
        print(
            'USECASE: Đang lọc theo khoảng giảm giá: min=$minDiscount, max=$maxDiscount');

        return discountedCourses.where((course) {
          final discount = course.getRealDiscountPercent();

          // Trường hợp đặc biệt cho khoảng 0-10%
          if (minDiscount == 0 && maxDiscount == 10) {
            final result = discount > 0 && discount <= 10;
            if (result) {
              print(
                  'USECASE: Khóa học ${course.title} phù hợp với khoảng 0-10%');
            }
            return result;
          }

          if (minDiscount != null && maxDiscount != null) {
            return discount >= minDiscount && discount <= maxDiscount;
          } else if (minDiscount != null) {
            return discount >= minDiscount;
          } else if (maxDiscount != null) {
            return discount <= maxDiscount;
          }
          return true;
        }).toList();
      }

      return discountedCourses;
    } else if (categoryId > 0) {
      return await courseRepository.getRelatedCourse(categoryId);
    } else {
      return await courseRepository.getAllCourses();
    }
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

  Future<List<CourseCardModel>> getRelatedCourse(int categoryId) async {
    return await courseRepository.getRelatedCourse(categoryId);
  }

  // Các phương thức cho combo courses

  /// Lấy danh sách combo khóa học với phân trang
  Future<CoursePaginationResponse> getComboCoursesWithPagination({
    String? title,
    int? accountId,
    int page = 0,
    int size = 10,
  }) async {
    return await courseRepository.getComboCoursesWithPagination(
      title: title,
      accountId: accountId,
      page: page,
      size: size,
    );
  }

  /// Lấy thông tin chi tiết về một combo khóa học
  Future<ComboCourseDetailModel?> getComboDetail(int id) async {
    return await courseRepository.getComboDetail(id);
  }

  /// Tìm kiếm combo khóa học theo tiêu đề
  Future<List<CourseCardModel>> searchComboCourses(String query) async {
    return await courseRepository.searchComboCourses(query);
  }
}
