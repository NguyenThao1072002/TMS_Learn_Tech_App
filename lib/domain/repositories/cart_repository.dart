import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/data/models/combo/course_bundle_model.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<bool> removeCartItem(int cartItemId);
  Future<bool> addToCart({
    required int itemId,
    required String type,
    required double price,
  });
  
  // Lấy danh sách combo cho một khóa học cụ thể
  Future<List<CourseBundle>> getCourseBundles(int courseId);
}
