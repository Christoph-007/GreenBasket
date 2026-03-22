import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/merchant_repository.dart';

class MerchantOrderController extends GetxController {
  final _repo = MerchantRepository();
  final isLoading = false.obs;
  
  final pendingOrders = <OrderModel>[].obs;
  final preparingOrders = <OrderModel>[].obs;
  final completedOrders = <OrderModel>[].obs;
  final cancelledOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      isLoading.value = true;
      final all = await _repo.getMerchantOrders();
      
      pendingOrders.assignAll(all.where((o) => o.status == 'pending'));
      preparingOrders.assignAll(all.where((o) => o.status == 'confirmed' || o.status == 'preparing'));
      completedOrders.assignAll(all.where((o) => o.status == 'delivered' || o.status == 'completed'));
      cancelledOrders.assignAll(all.where((o) => o.status == 'cancelled'));
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _repo.updateOrderStatus(orderId, status);
      fetchAllOrders();
      Get.snackbar('Success', 'Order status updated to $status');
    } catch (_) {}
  }
}
