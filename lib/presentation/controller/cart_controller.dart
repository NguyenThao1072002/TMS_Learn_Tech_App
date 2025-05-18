import 'package:flutter/material.dart';
import 'package:tms_app/data/models/cart/cart_model.dart';
import 'package:tms_app/data/models/combo/course_bundle_model.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';

class CartController {
  final CartUseCase cartUseCase;
  final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<double> cartTotal = ValueNotifier(0.0);
  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
  
  // Thêm ValueNotifier cho danh sách combo đề xuất
  final ValueNotifier<List<CourseBundle>> suggestedBundles = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingBundles = ValueNotifier(false);

  CartController({required this.cartUseCase}) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadCartItems();
  }

  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    final errorDetail = stackTrace != null
        ? '$message: $error\nStack trace: $stackTrace'
        : '$message: $error';

    print(errorDetail);
    errorMessage.value = message;
  }

// Trong CartController
  Future<void> loadCartItems() async {
    print("Starting to load cart items, current loading state: ${isLoading.value}");
    if (isLoading.value) {
      print("Already loading, returning early");
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    print("Set loading to true");

    try {
      final items = await cartUseCase.getCartItems();
      print("Successfully loaded ${items.length} items");
      
      // Log thông tin chi tiết về các mục trong giỏ hàng
      for (var item in items) {
        print("Cart item: ID=${item.cartItemId}, Name=${item.name}, Type=${item.type}, Image=${item.image}");
        if (item.type.toUpperCase() == 'COMBO') {
          print("Found COMBO in cart: ${item.name}, ID: ${item.cartItemId}, BundleId: ${item.courseBundleId}");
        }
      }

      cartItems.value = items;
      print("Updated cartItems.value with ${cartItems.value.length} items");

      await updateCartTotal();
      print("Updated cart total: ${cartTotal.value}");
    } catch (e, stackTrace) {
      print("Error loading cart items: $e");
      _logError('Không thể tải giỏ hàng', e, stackTrace);
    } finally {
      isLoading.value = false;
      print("Set loading to false");
    }
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    try {
      await loadCartItems();
    } catch (e, stackTrace) {
      _logError('Không thể làm mới giỏ hàng', e, stackTrace);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<bool> addToCart({
    required int itemId,
    required String type,
    required double price,
  }) async {
    try {
      final isInCart =
          await cartUseCase.isItemInCart(itemId: itemId, type: type);
      if (isInCart) {
        errorMessage.value = 'Sản phẩm đã có trong giỏ hàng';
        return false;
      }

      final success = await cartUseCase.addToCart(
        itemId: itemId,
        type: type,
        price: price,
      );

      if (success) {
        await loadCartItems();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _logError('Không thể thêm vào giỏ hàng', e, stackTrace);
      return false;
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    try {
      print('CartController: Bắt đầu xóa item có ID: $cartItemId');
      
      // Kiểm tra xem cartItemId có hợp lệ không
      if (cartItemId <= 0) {
        print('CartController: cartItemId không hợp lệ: $cartItemId');
        return false;
      }
      
      final success = await cartUseCase.removeCartItem(cartItemId);
      
      print('CartController: Kết quả xóa item: $success');
      
      if (success) {
        // Tải lại danh sách giỏ hàng sau khi xóa thành công
        await loadCartItems();
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      _logError('Không thể xóa khỏi giỏ hàng', e, stackTrace);
      print('CartController: Chi tiết lỗi khi xóa item: $e');
      return false;
    }
  }

  Future<void> updateCartTotal() async {
    try {
      final total = await cartUseCase.calculateCartTotal();
      cartTotal.value = total;
    } catch (e, stackTrace) {
      _logError('Không thể tính tổng giỏ hàng', e, stackTrace);
    }
  }

  Future<void> loadCourseBundles(int courseId) async {
    isLoadingBundles.value = true;
    errorMessage.value = null;
    
    try {
      final bundles = await cartUseCase.getCourseBundles(courseId);
      suggestedBundles.value = bundles;
      print("Loaded ${bundles.length} course bundles for courseId: $courseId");
    } catch (e, stackTrace) {
      print("Error loading course bundles: $e");
      _logError('Không thể tải gói combo', e, stackTrace);
    } finally {
      isLoadingBundles.value = false;
    }
  }
  
 

  void dispose() {
    cartItems.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    cartTotal.dispose();
    isRefreshing.dispose();
    suggestedBundles.dispose();
    isLoadingBundles.dispose();
  }
}
