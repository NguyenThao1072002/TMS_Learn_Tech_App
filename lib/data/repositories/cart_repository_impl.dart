import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/data/services/cart/cart_service.dart';
import 'package:tms_app/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartService cartService;

  CartRepositoryImpl({required this.cartService});

  @override
  Future<List<CartItem>> getCartItems() async {
    return await cartService.getCartItems();
  }

  @override
  Future<bool> removeCartItem(int cartItemId) async {
    return await cartService.removeCartItem(cartItemId);
  }

  @override
  Future<bool> addToCart({
    required int itemId,
    required String type,
    required double price,
  }) async {
    return await cartService.addToCart(
      itemId: itemId,
      type: type,
      price: price,
    );
  }
}
