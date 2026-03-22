import '../providers/api_provider.dart';
import '../models/order_model.dart';

class OrderRepository {
  final _api = ApiProvider();

  // Cart
  Future<List<CartItemModel>> getCart() async {
    final response = await _api.get('/cart');
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] as List<dynamic>? ?? [];
    return items.map((e) => CartItemModel.fromJson(e)).toList();
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
    String? preparationOption,
  }) async {
    await _api.post('/cart', data: {
      'productId': productId,
      'quantity': quantity,
      if (preparationOption != null) 'preparationOption': preparationOption,
    });
  }

  Future<void> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    await _api.put('/cart/$productId', data: {'quantity': quantity});
  }

  Future<void> removeFromCart(String productId) async {
    await _api.delete('/cart/$productId');
  }

  Future<void> clearCart() async {
    await _api.delete('/cart');
  }

  Future<Map<String, dynamic>> applyCoupon(String code) async {
    final response = await _api.post('/cart/coupon', data: {'code': code});
    return response.data as Map<String, dynamic>;
  }

  // Orders
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
  }) async {
    final response = await _api.get('/orders', params: {
      if (status != null) 'status': status,
      'page': page,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrder(String id) async {
    final response = await _api.get('/orders/$id');
    final data = response.data as Map<String, dynamic>;
    return OrderModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final response = await _api.post('/checkout', data: {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      if (couponCode != null) 'couponCode': couponCode,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    await _api.post('/orders/$orderId/cancel', data: {'reason': reason});
  }

  // Addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _api.get('/user/addresses');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final response =
        await _api.post('/user/addresses', data: address.toJson());
    final data = response.data as Map<String, dynamic>;
    return AddressModel.fromJson(data['data']);
  }

  Future<void> deleteAddress(String id) async {
    await _api.delete('/user/addresses/$id');
  }
}
