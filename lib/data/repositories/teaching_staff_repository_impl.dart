import '../../domain/repositories/teaching_staff_repository.dart';
import '../models/teaching_staff/teaching_staff_model.dart';
import '../models/teaching_staff/teaching_staff_detail_model.dart';
import '../models/teaching_staff/course_of_teaching_staff_model.dart';
import '../services/teaching_staff/teaching_staff_service.dart';

class TeachingStaffRepositoryImpl implements TeachingStaffRepository {
  final TeachingStaffService teachingStaffService;

  TeachingStaffRepositoryImpl({required this.teachingStaffService});

  @override
  Future<TeachingStaffResponse> getTeachingStaffs({
    int page = 0,
    int size = 10,
    String? search,
    int? categoryId,
  }) async {
    return await teachingStaffService.getTeachingStaffs(
      page: page,
      size: size,
      search: search,
      categoryId: categoryId,
    );
  }

  @override
  Future<TeachingStaffDetailResponse> getTeachingStaffDetailById(int id) async {
    return await teachingStaffService.getTeachingStaffDetailById(id);
  }

  @override
  Future<List<TeachingStaff>> getFeaturedTeachingStaffs({int limit = 5}) async {
    return await teachingStaffService.getFeaturedTeachingStaffs(limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getCoursesOfTeachingStaff({
    required int accountId,
    int page = 0,
    int size = 10,
  }) async {
    return await teachingStaffService.getCoursesOfTeachingStaff(
      accountId: accountId,
      page: page,
      size: size,
    );
  }
}
