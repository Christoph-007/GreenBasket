import 'package:get/get.dart';
import '../../data/repositories/admin_repository.dart';

class AdminController extends GetxController {
  final _repo = AdminRepository();
  final isLoading = false.obs;
  
  final totalUsersCount = 0.obs;
  final totalOrdersCount = 0.obs;
  final revenueValue = "₹0.00".obs;
  final pendingActionsCount = 0.obs;
  
  final merchantApprovalsCount = 0.obs;
  final agentVerificationsCount = 0.obs;
  
  final recentOrdersList = [].obs;
  final orders = <dynamic>[].obs;
  final stats = <String, dynamic>{}.obs;

  final merchants = <dynamic>[].obs;
  final users = <dynamic>[].obs;
  final products = <dynamic>[].obs;
  final agents = <dynamic>[].obs;
  final payouts = <dynamic>[].obs;
  final categories = <dynamic>[].obs;
  final recipes = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchStats(),
      fetchOrders(),
      fetchMerchants(),
      fetchUsers(),
      fetchProducts(),
      fetchAgents(),
      fetchPayouts(),
      fetchCategories(),
      fetchRecipes(),
    ]);
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final response = await _repo.getStats();
      final data = response['data'] ?? response;
      stats.value = data;
      
      totalUsersCount.value = data['totalUsers'] ?? 0;
      totalOrdersCount.value = data['totalOrders'] ?? 0;
      revenueValue.value = "₹${data['revenue'] ?? data['totalRevenue'] ?? 0}";
      pendingActionsCount.value = data['pendingActions'] ?? 0;
      
      merchantApprovalsCount.value = data['pendingMerchants'] ?? 0;
      agentVerificationsCount.value = data['pendingAgents'] ?? 0;
      
      recentOrdersList.assignAll(data['recentOrders'] ?? []);
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await _repo.getUnassignedOrders(); // Using unassigned as "all" for now
      orders.assignAll(response);
    } catch (_) {}
  }

  Future<void> fetchMerchants() async {
    try {
      final data = await _repo.getAllMerchants();
      merchants.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchUsers() async {
    try {
      final data = await _repo.getUsers();
      users.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchProducts() async {
    try {
      final data = await _repo.getAllProducts();
      products.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchAgents() async {
    try {
      final data = await _repo.getAllAgents();
      agents.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchPayouts() async {
    try {
      final data = await _repo.getPayoutRequests();
      payouts.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _repo.getAllCategories();
      categories.assignAll(data);
    } catch (_) {}
  }

  Future<void> fetchRecipes() async {
    try {
      final data = await _repo.getAllRecipes();
      recipes.assignAll(data);
    } catch (_) {}
  }

  Future<void> verifyMerchant(String id, bool approved) async {
    try {
      await _repo.verifyMerchant(id, approved);
      Get.snackbar('Success', approved ? 'Merchant Approved' : 'Merchant Rejected',
          backgroundColor: approved ? Get.theme.primaryColor : Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onPrimary);
      fetchAll();
    } catch (_) {}
  }

  Future<void> toggleUserBlock(String id) async {
    try {
      await _repo.toggleUserBlock(id);
      fetchUsers();
    } catch (_) {}
  }

  Future<void> verifyAgent(String id, bool verified) async {
    try {
      await _repo.verifyAgent(id, verified);
      fetchAgents();
      fetchStats();
    } catch (_) {}
  }

  Future<void> processPayout(String id, bool approved) async {
    try {
      await _repo.processPayout(id);
      fetchPayouts();
      fetchStats();
      Get.snackbar('Success', 'Payout Processed');
    } catch (_) {}
  }

  Future<void> bulkProcessPayouts(List<String> ids, bool approved) async {
    try {
      await _repo.bulkProcessPayouts();
      fetchPayouts();
      fetchStats();
      Get.snackbar('Success', 'Bulk Payouts Processed');
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getOrderDetail(String id) async {
    return await _repo.getOrderDetail(id);
  }

  Future<void> logout() async {
    // Implement logout logic
    Get.offAllNamed('/login');
  }
}
