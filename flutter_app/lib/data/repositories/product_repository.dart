import '../providers/api_provider.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _api = ApiProvider();

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? search,
    bool? isOrganic,
    bool? isFeatured,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get('/products', params: {
      if (categoryId != null) 'category': categoryId,
      if (search != null) 'search': search,
      if (isOrganic != null) 'isOrganic': isOrganic,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (sortBy != null) 'sortBy': sortBy,
      'page': page,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _api.get('/products/$id');
    final data = response.data as Map<String, dynamic>;
    return ProductModel.fromJson(data['data']);
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get('/categories');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    final response = await _api.get('/search', params: {'q': query});
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> addToWishlist(String productId) async {
    await _api.post('/wishlist/$productId');
  }

  Future<void> removeFromWishlist(String productId) async {
    await _api.delete('/wishlist/$productId');
  }

  Future<List<ProductModel>> getWishlist() async {
    final response = await _api.get('/wishlist');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items.map((e) => ProductModel.fromJson(e['product'])).toList();
  }
}
