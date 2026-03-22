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
      if (result['success'] == true || result['data'] != null) {
        final data = result['data'] ?? result;
        storeName.value =
            data['storeName'] ?? data['businessName'] ?? data['name'] ?? '';
        isVerified.value = data['isVerified'] ?? data['verified'] ?? false;
        isStoreOpen.value = data['isStoreOpen'] ?? data['isOpen'] ?? true;
      }
    } catch (_) {}
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final stats = await _repo.getDashboardStats();
      if (stats['success'] == true) {
        final data = stats['data'];
        revenue.value = '₹${data['todayRevenue'] ?? 0}';
        orderCount.value = data['todayOrders'] ?? 0;
        rating.value = (data['storeRating'] ?? 0.0).toDouble();
        isStoreOpen.value = data['isStoreOpen'] ?? isStoreOpen.value;
      }
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNewOrders() async {
    try {
      final orders = await _repo.getMerchantOrders(status: 'pending');
      newOrders.assignAll(orders);
    } catch (_) {}
  }

  Future<void> toggleStoreStatus(bool? val) async {
    try {
      await _repo.toggleStoreStatus();
      isStoreOpen.toggle();
    } catch (_) {}
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      await _repo.updateOrderStatus(orderId, 'confirmed');
      fetchNewOrders();
      Get.snackbar('Success', 'Order accepted successfully');
    } catch (_) {}
  }

  Future<void> declineOrder(String orderId) async {
    try {
      await _repo.updateOrderStatus(orderId, 'cancelled');
      fetchNewOrders();
      Get.snackbar('Order Declined', 'Order has been cancelled');
    } catch (_) {}
  }
}
