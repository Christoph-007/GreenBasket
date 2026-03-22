import 'package:get/get.dart';

class AdminController extends GetxController {
  final isLoading = false.obs;
  
  // Dummy data for now, should be fetched from repository later
  final totalUsers = 24818.obs;
  final ordersToday = 1284.obs;
  final revenue = "₹14.8L".obs;
  final pendingActions = 7.obs;
  
  final merchantApprovals = 3.obs;
  final agentVerifications = 2.obs;
  
  final recentOrders = [
    {'id': 'GB-4820', 'status': 'Delivered', 'color': 'success'},
    {'id': 'GB-4819', 'status': 'Preparing', 'color': 'warning'},
    {'id': 'GB-4818', 'status': 'Out for Delivery', 'color': 'info'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    // TODO: Implement actual API fetch
  }
}
