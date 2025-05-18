import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/cart/cart_model.dart';

import 'package:get_it/get_it.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/combo/course_bundle_model.dart';

class CartService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  CartService([Dio? dioInstance]) : dio = dioInstance ?? GetIt.instance<Dio>();

  // Hàm 1: Lấy danh sách giỏ hàng (đã cập nhật theo userId)
  Future<List<CartItem>> getCartItems() async {
    try {
      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('jwt');

      if (userId == null || userId.isEmpty) {
        print("User ID not found. Please login again.");
        return [];
      }

      final response = await dio.get(
        '$baseUrl/api/cart/$userId', // Cập nhật endpoint theo userId
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token != null ? 'Bearer $token' : null,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Sử dụng ApiResponseHelper để xử lý phản hồi
        return ApiResponseHelper.processList(response.data, CartItem.fromJson);
      } else {
        print('Lỗi khi lấy giỏ hàng: ${response.statusCode}');
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách giỏ hàng: $e');
      return [];
    }
  }

  // Hàm 2: Xóa một item khỏi giỏ hàng (đã cập nhật theo format API mới)
  Future<bool> removeCartItem(int cartItemId) async {
  try {
    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null || token.isEmpty) {
      print("JWT token không tìm thấy. Vui lòng đăng nhập lại.");
      return false;
    }

    final response = await dio.delete(
      '$baseUrl/api/cart/$cartItemId/remove', // Sử dụng cartItemId trong đường dẫn
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Đã xóa item $cartItemId khỏi giỏ hàng');
      return true;
    } else {
      print('Lỗi khi xóa item khỏi giỏ hàng: ${response.statusCode}');
      throw Exception('Failed to remove cart item: ${response.statusCode}');
    }
  } catch (e) {
    print('Lỗi khi xóa item khỏi giỏ hàng: $e');
    return false;
  }
  }
  // Thêm item vào giỏ hàng (khóa học, bài thi, combo)
  Future<bool> addToCart({
    required int itemId,
    required String type, // "COURSE", "EXAM", hoặc "COMBO"
    required double price,
  }) async {
    try {
      // Lấy token và userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final userId = prefs.getString('userId');

      if (token == null || token.isEmpty) {
        print("JWT token không tìm thấy. Vui lòng đăng nhập lại.");
        return false;
      }

      if (userId == null || userId.isEmpty) {
        print("User ID không tìm thấy. Vui lòng đăng nhập lại.");
        return false;
      }

      // Chuẩn bị dữ liệu cho request
      final Map<String, dynamic> data = {
        "type": type,
        "price": price,
      };

      // Thêm trường ID phù hợp dựa vào loại
      switch (type.toUpperCase()) {
        case "COURSE":
          data["courseId"] = itemId;
          break;
        case "EXAM":
          data["testId"] = itemId;
          break;
        case "COMBO":
          data["courseBundleId"] = itemId;
          break;
        default:
          data["courseId"] = itemId; // Mặc định xử lý như khóa học
      }

      print('Đang thêm item vào giỏ hàng: $data');

      // Thực hiện request
      final response = await dio.post(
        '$baseUrl/api/cart/$userId/add-item',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Kiểm tra kết quả
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Thêm item vào giỏ hàng thành công: ID=$itemId, Type=$type');
        return true;
      } else {
        print(
            'Lỗi khi thêm item vào giỏ hàng (${response.statusCode}): ${response.data}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi thêm item vào giỏ hàng: $e');
      if (e is DioException) {
        print('Chi tiết lỗi: ${e.response?.data}');
      }
      return false;
    }
  }

  // Lấy danh sách combo cho một khóa học cụ thể
  Future<List<CourseBundle>> getCourseBundles(int courseId) async {
    try {
      // Lấy token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final response = await dio.get(
        '$baseUrl/api/cart/course/$courseId/bundles',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token != null ? 'Bearer $token' : null,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Xử lý phản hồi dữ liệu
        return ApiResponseHelper.processList(response.data, CourseBundle.fromJson);
      } else {
        print('Lỗi khi lấy combo: ${response.statusCode}');
        throw Exception('Failed to load course bundles: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách combo: $e');
      return [];
    }
  }
}
