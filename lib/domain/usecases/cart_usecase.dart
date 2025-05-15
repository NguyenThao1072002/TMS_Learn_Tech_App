import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/domain/repositories/cart_repository.dart';

class CartUseCase {
  final CartRepository cartRepository;

  CartUseCase(this.cartRepository);

  Future<List<CartItem>> getCartItems() async {
    return await cartRepository.getCartItems();
  }

  Future<bool> removeCartItem(int cartItemId) async {
    return await cartRepository.removeCartItem(cartItemId);
  }

  Future<bool> addToCart({
    required int itemId,
    required String type,
    required double price,
  }) async {
    return await cartRepository.addToCart(
      itemId: itemId,
      type: type,
      price: price,
    );
  }

  // Tính tổng giá trị giỏ hàng
  Future<double> calculateCartTotal() async {
    final cartItems = await getCartItems();
    double total = 0.0;

    for (var item in cartItems) {
      // Tính giá sau khi áp dụng giảm giá (nếu có)
      double itemPrice = item.price;
      if (item.discount > 0) {
        itemPrice = itemPrice - (itemPrice * item.discount / 100);
      }
      total += itemPrice;
    }

    return total;
  }

  // Kiểm tra xem một item đã tồn tại trong giỏ hàng chưa
  Future<bool> isItemInCart({
    required int itemId,
    required String type,
  }) async {
    final cartItems = await getCartItems();

    for (var item in cartItems) {
      bool isMatch = false;

      if (type == "COURSE" && item.courseId == itemId) {
        isMatch = true;
      } else if (type == "EXAM" && item.testId == itemId) {
        isMatch = true;
      } else if ((type == "COMBO" || type == "BUNDLE") &&
          item.courseBundleId == itemId) {
        isMatch = true;
      }

      if (isMatch && item.type.toUpperCase() == type.toUpperCase()) {
        return true;
      }
    }

    return false;
  }
}
