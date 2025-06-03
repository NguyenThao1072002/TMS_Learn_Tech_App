import 'package:tms_app/data/models/teaching_staff/teaching_staff_model.dart';
import 'package:tms_app/data/models/teaching_staff/teaching_staff_detail_model.dart';
import 'package:tms_app/domain/repositories/teaching_staff_repository.dart';

class TeachingStaffUseCase {
  final TeachingStaffRepository repository;

  TeachingStaffUseCase(this.repository);

  /// Lấy danh sách giảng viên với phân trang và tìm kiếm
  /// [page] - Trang hiện tại (mặc định là 0)
  /// [size] - Số lượng giảng viên trên mỗi trang (mặc định là 10)
  /// [search] - Từ khóa tìm kiếm (tùy chọn)
  /// [categoryId] - ID chuyên môn để lọc giảng viên (tùy chọn)
  Future<TeachingStaffResponse> getTeachingStaffs({
    int page = 0,
    int size = 10,
    String? search,
    int? categoryId,
  }) async {
    return await repository.getTeachingStaffs(
      page: page,
      size: size,
      search: search,
      categoryId: categoryId,
    );
  }

  /// Lấy chi tiết đầy đủ thông tin giảng viên theo ID
  /// [id] - ID của giảng viên cần lấy thông tin chi tiết
  Future<TeachingStaffDetailResponse> getTeachingStaffDetailById(int id) async {
    return await repository.getTeachingStaffDetailById(id);
  }

  /// Lấy danh sách giảng viên nổi bật
  /// [limit] - Số lượng giảng viên cần lấy
  Future<List<TeachingStaff>> getFeaturedTeachingStaffs({int limit = 5}) async {
    return await repository.getFeaturedTeachingStaffs(limit: limit);
  }
}
