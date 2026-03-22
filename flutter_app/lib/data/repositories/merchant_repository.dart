import '../providers/api_provider.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class MerchantRepository {
  final _api = ApiProvider();

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/merchants/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.put('/merchants/profile', data: data);
  }

  Future<void> toggleStoreStatus() async {
    await _api.patch('/merchants/toggle-store');
  }

  // ─── Dashboard Stats ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get('/merchants/dashboard-stats');
    return response.data as Map<String, dynamic>;
  }

  // ─── Order Management ─────────────────────────────────────────────────────

  Future<List<OrderModel>> getMerchantOrders({String? status}) async {
    final response = await _api.get('/orders/merchant', params: {
      if (status != null) 'status': status,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _api.patch('/orders/$orderId/status', data: {'status': status});
  }

  Future<List<Map<String, dynamic>>> getAvailableAgents() async {
    final response = await _api.get('/agents/available');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> assignAgentToOrder(String orderId, String agentId) async {
    await _api.patch('/orders/$orderId/assign-agent',
        data: {'agentId': agentId});
  }

  // ─── Product Management ───────────────────────────────────────────────────

  Future<List<ProductModel>> getMyProducts() async {
    final response = await _api.get('/products/merchant/my-products');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _api.post('/products', data: product);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    await _api.put('/products/$id', data: product);
  }

  Future<void> updateStock(String id, int stock) async {
    await _api.patch('/products/$id/stock', data: {'stock': stock});
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('/products/$id');
  }

  Future<List<Map<String, dynamic>>> getUploadHistory() async {
    final response = await _api.get('/products/merchant/bulk-upload-history');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> bulkUploadProducts(String filePath) async {
    await _api.uploadFile(
      '/products/merchant/bulk-upload',
      filePath: filePath,
      extraFields: {'fileType': 'csv'},
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _api.get('/categories');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  // ─── Offers / Discounts ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOffers({String? status}) async {
    final response = await _api.get('/merchant/offers', params: {
      if (status != null) 'status': status,
    });
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> data) async {
    final response = await _api.post('/merchant/offers', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateOffer(String id, Map<String, dynamic> data) async {
    await _api.put('/merchant/offers/$id', data: data);
  }

  Future<void> deleteOffer(String id) async {
    await _api.delete('/merchant/offers/$id');
  }

  Future<void> toggleOffer(String id, bool active) async {
    await _api.patch('/merchant/offers/$id/toggle',
        data: {'active': active});
  }

  Future<Map<String, dynamic>> getOfferAnalytics(String offerId) async {
    final response = await _api.get('/merchant/offers/$offerId/analytics');
    return response.data as Map<String, dynamic>;
  }

  // ─── Analytics ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics({String period = 'month'}) async {
    final response =
        await _api.get('/merchant-analytics', params: {'period': period});
    return response.data as Map<String, dynamic>;
  }

  // ─── Financial ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getFinancialSummary(
      {String period = 'month'}) async {
    final response = await _api.get('/financial/summary',
        params: {'period': period});
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTransactions(
      {String period = 'month'}) async {
    final response = await _api.get('/financial/transactions',
        params: {'period': period});
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  // ─── Payouts ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPayoutSummary() async {
    final response = await _api.get('/financial/payout-summary');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPayouts() async {
    final response = await _api.get('/financial/payouts');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<Map<String, dynamic>> requestPayout() async {
    final response = await _api.post('/financial/payouts/request');
    return response.data as Map<String, dynamic>;
  }

  // ─── Documents ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final response = await _api.get('/merchant/documents');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> uploadDocument(
      String type, String filePath, String? docNumber) async {
    await _api.uploadFile(
      '/merchant/documents/upload',
      filePath: filePath,
      extraFields: {
        'type': type,
        if (docNumber != null) 'docNumber': docNumber,
      },
    );
  }

  // ─── Delivery Zones ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDeliveryZones() async {
    final response = await _api.get('/merchant/zones');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> createZone(Map<String, dynamic> data) async {
    await _api.post('/merchant/zones', data: data);
  }

  Future<void> updateZone(String id, Map<String, dynamic> data) async {
    await _api.put('/merchant/zones/$id', data: data);
  }

  Future<void> deleteZone(String id) async {
    await _api.delete('/merchant/zones/$id');
  }

  Future<void> toggleZone(String id, bool active) async {
    await _api.patch('/merchant/zones/$id/toggle', data: {'active': active});
  }

  // ─── Store Settings ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStoreSettings() async {
    final response = await _api.get('/merchant/settings');
    return response.data as Map<String, dynamic>;
  }

  Future<void> saveStoreSettings(Map<String, dynamic> data) async {
    await _api.put('/merchant/settings', data: data);
  }

  // ─── Subscriptions ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSubscriptions(
      {String? status}) async {
    final response = await _api.get('/merchant/subscriptions', params: {
      if (status != null) 'status': status,
    });
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> pauseSubscription(String id) async {
    await _api.patch('/merchant/subscriptions/$id/pause');
  }

  Future<void> resumeSubscription(String id) async {
    await _api.patch('/merchant/subscriptions/$id/resume');
  }
}
