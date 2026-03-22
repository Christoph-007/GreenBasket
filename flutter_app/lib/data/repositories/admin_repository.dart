import 'package:greenbasket_app/data/providers/api_provider.dart';

class AdminRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getStats() async {
    final response = await _api.get('/admin/stats');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAllMerchants() async {
    final response = await _api.get('/admin/merchants');
    final data = response.data as Map<String, dynamic>;
    return data['merchants'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> getPendingMerchants() async {
    final response = await _api.get('/admin/merchants/pending');
    final data = response.data as Map<String, dynamic>;
    return data['merchants'] as List<dynamic>? ?? [];
  }

  Future<void> verifyMerchant(String id, bool approved) async {
    await _api.patch('/admin/merchants/$id/verify', data: {'approved': approved});
  }

  Future<List<dynamic>> getUsers() async {
    final response = await _api.get('/admin/users');
    final data = response.data as Map<String, dynamic>;
    return data['users'] as List<dynamic>? ?? [];
  }

  Future<void> toggleUserBlock(String id) async {
    await _api.patch('/admin/users/$id/block');
  }

  // Agent Management
  Future<List<dynamic>> getAllAgents() async {
    final response = await _api.get('/admin/agents');
    final data = response.data as Map<String, dynamic>;
    return data['agents'] as List<dynamic>? ?? [];
  }

  Future<void> verifyAgent(String id, bool verified) async {
    await _api.patch('/admin/agents/$id/verify', data: {'verified': verified});
  }

  // Orders
  Future<List<dynamic>> getUnassignedOrders() async {
    final response = await _api.get('/admin/orders/unassigned');
    final data = response.data as Map<String, dynamic>;
    return data['orders'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getOrderDetail(String id) async {
    final response = await _api.get('/admin/orders/$id');
    final data = response.data as Map<String, dynamic>;
    return (data['order'] ?? data) as Map<String, dynamic>;
  }

  Future<void> manualAssign(String orderId, String agentId) async {
    await _api.post('/admin/orders/$orderId/assign/$agentId');
  }

  // Inventory Management
  Future<List<dynamic>> getAllProducts() async {
    final response = await _api.get('/admin/products');
    final data = response.data as Map<String, dynamic>;
    return data['products'] as List<dynamic>? ?? [];
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('/admin/products/$id');
  }

  Future<List<dynamic>> getAllCategories() async {
    final response = await _api.get('/admin/categories');
    final data = response.data as Map<String, dynamic>;
    return data['categories'] as List<dynamic>? ?? [];
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('/admin/categories/$id');
  }

  Future<List<dynamic>> getAllRecipes() async {
    final response = await _api.get('/admin/recipes');
    final data = response.data as Map<String, dynamic>;
    return data['recipes'] as List<dynamic>? ?? [];
  }

  Future<void> deleteRecipe(String id) async {
    await _api.delete('/admin/recipes/$id');
  }

  // Finance & Payouts
  Future<List<dynamic>> getPayoutRequests() async {
    final response = await _api.get('/admin/finance/payouts');
    final data = response.data as Map<String, dynamic>;
    return data['payouts'] as List<dynamic>? ?? [];
  }

  Future<void> processPayout(String id) async {
    await _api.post('/admin/finance/payouts/$id/process');
  }

  Future<void> bulkProcessPayouts() async {
    await _api.post('/admin/finance/payouts/bulk-process');
  }
}
