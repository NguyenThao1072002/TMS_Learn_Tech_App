import 'package:dio/dio.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/api_response_helper.dart';
import '../../models/teaching_staff/teaching_staff_model.dart';
import '../../models/teaching_staff/teaching_staff_detail_model.dart';

class TeachingStaffService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  TeachingStaffService(this.dio);

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
    try {
      // Xây dựng query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      // Gọi API
      final endpoint = '$baseUrl/lecturers';

      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) => true,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return TeachingStaffResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Lỗi khi lấy danh sách giảng viên: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  /// Lấy chi tiết đầy đủ thông tin giảng viên theo ID
  /// [id] - ID của giảng viên cần lấy thông tin chi tiết
  Future<TeachingStaffDetailResponse> getTeachingStaffDetailById(int id) async {
    try {
      final endpoint = '$baseUrl/lecturers/$id/detail';

      final response = await dio.get(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return TeachingStaffDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Lỗi khi lấy chi tiết giảng viên: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  /// Lấy danh sách giảng viên nổi bật
  /// [limit] - Số lượng giảng viên cần lấy
  Future<List<TeachingStaff>> getFeaturedTeachingStaffs({int limit = 5}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': 0,
        'size': limit,
        'sort': 'averageRating,desc', // Sắp xếp theo đánh giá giảm dần
      };

      final endpoint = '$baseUrl/lecturers';

      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) => true,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final staffResponse = TeachingStaffResponse.fromJson(response.data);
        return staffResponse.data.content;
      } else {
        throw Exception(
            'Lỗi khi lấy danh sách giảng viên nổi bật: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
