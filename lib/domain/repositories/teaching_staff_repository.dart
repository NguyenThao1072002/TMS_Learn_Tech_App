import '../../data/models/teaching_staff/teaching_staff_model.dart';

// Interface định nghĩa các phương thức làm việc với giảng viên
abstract class TeachingStaffRepository {
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
  });

  /// Lấy chi tiết thông tin giảng viên theo ID
  /// [id] - ID của giảng viên cần lấy thông tin
  Future<TeachingStaff?> getTeachingStaffById(int id);

  /// Lấy danh sách giảng viên nổi bật
  /// [limit] - Số lượng giảng viên cần lấy
  Future<List<TeachingStaff>> getFeaturedTeachingStaffs({int limit = 5});
}
