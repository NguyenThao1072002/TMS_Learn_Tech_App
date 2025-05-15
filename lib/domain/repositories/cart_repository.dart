import 'package:tms_app/data/models/cart/cart_model.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<bool> removeCartItem(int cartItemId);
  Future<bool> addToCart({
    required int itemId,
    required String type,
    required double price,
  });
}
