import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/repositories/merchant_repository.dart';
import '../../data/models/order_model.dart';

class MerchantController extends GetxController {
  final _repo = MerchantRepository();
  final isLoading = false.obs;
  final isStoreOpen = true.obs;

  final revenue = '₹0'.obs;
  final orderCount = 0.obs;
  final rating = 0.0.obs;
  final storeName = ''.obs;
  final isVerified = false.obs;

  final newOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchStats();
    fetchNewOrders();
  }

  Future<void> fetchProfile() async {
    try {
      final result = await _repo.getProfile();
      final data = result['data'] ?? result;
      storeName.value =
          data['storeName'] ?? data['businessName'] ?? data['name'] ?? '';
      isVerified.value = data['isVerified'] ?? data['verified'] ?? false;
      isStoreOpen.value = data['isStoreOpen'] ?? data['isOpen'] ?? true;
    } catch (e) {
      debugPrint('[MerchantController] fetchProfile error: $e');
    }
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final stats = await _repo.getDashboardStats();
      // Support both { data: {...} } and flat response shapes
      final data = stats['data'] ?? stats;
      revenue.value = '₹${data['todayRevenue'] ?? data['revenue'] ?? 0}';
      orderCount.value = data['todayOrders'] ?? data['orders'] ?? 0;
      rating.value =
          ((data['storeRating'] ?? data['rating'] ?? 0.0) as num).toDouble();
      isStoreOpen.value =
          data['isStoreOpen'] ?? data['isOpen'] ?? isStoreOpen.value;
    } catch (e) {
      debugPrint('[MerchantController] fetchStats error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNewOrders() async {
    try {
      final orders = await _repo.getMerchantOrders(status: 'pending');
      newOrders.assignAll(orders);
    } catch (e) {
      debugPrint('[MerchantController] fetchNewOrders error: $e');
    }
  }

  Future<void> toggleStoreStatus(bool? val) async {
    try {
      await _repo.toggleStoreStatus();
      isStoreOpen.toggle();
    } catch (e) {
      debugPrint('[MerchantController] toggleStoreStatus error: $e');
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      await _repo.updateOrderStatus(orderId, 'confirmed');
      fetchNewOrders();
      Get.snackbar('Success', 'Order accepted successfully');
    } catch (e) {
      debugPrint('[MerchantController] acceptOrder error: $e');
      Get.snackbar('Error', 'Failed to accept order');
    }
  }

  Future<void> declineOrder(String orderId) async {
    try {
      await _repo.updateOrderStatus(orderId, 'cancelled');
      fetchNewOrders();
      Get.snackbar('Order Declined', 'Order has been cancelled');
    } catch (e) {
      debugPrint('[MerchantController] declineOrder error: $e');
      Get.snackbar('Error', 'Failed to decline order');
    }
  }
}
