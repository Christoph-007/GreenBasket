import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final _repo = OrderRepository();

  final items = <CartItemModel>[].obs;
  final isLoading = false.obs;
  final appliedCoupon = ''.obs;
  final discount = 0.0.obs;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.itemTotal);
  double get deliveryFee => subtotal > 500 ? 0 : 40;
  double get total => subtotal + deliveryFee - discount.value;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading.value = true;
    try {
      items.value = await _repo.getCart();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> addItem({
    required String productId,
    required int quantity,
    String? preparationOption,
  }) async {
    try {
      await _repo.addToCart(
        productId: productId,
        quantity: quantity,
        preparationOption: preparationOption,
      );
      await fetchCart();
      Get.snackbar(
        'Added to Cart',
        'Item has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to add item to cart',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await _repo.removeFromCart(productId);
      } else {
        await _repo.updateCartItem(
            productId: productId, quantity: quantity);
      }
      await fetchCart();
    } catch (_) {}
  }

  Future<void> removeItem(String productId) async {
    try {
      await _repo.removeFromCart(productId);
      await fetchCart();
    } catch (_) {}
  }

  Future<void> applyCoupon(String code) async {
    try {
      final result = await _repo.applyCoupon(code);
      if (result['success'] == true) {
        appliedCoupon.value = code;
        discount.value = (result['data']?['discount'] ?? 0).toDouble();
        Get.snackbar('Coupon Applied', 'Discount of ₹${discount.value.toInt()} applied');
      } else {
        Get.snackbar('Invalid Coupon', result['message'] ?? 'Coupon not valid');
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to apply coupon');
    }
  }

  void clearCoupon() {
    appliedCoupon.value = '';
    discount.value = 0;
  }
}
