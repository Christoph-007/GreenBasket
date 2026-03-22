import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class HomeController extends GetxController {
  final _productRepo = ProductRepository();

  final isLoading = false.obs;
  final categories = <CategoryModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final flashSaleProducts = <ProductModel>[].obs;
  final bannerImages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    await Future.wait([
      _fetchCategories(),
      _fetchFeatured(),
      _fetchFlashSales(),
    ]);
    isLoading.value = false;
  }

  Future<void> _fetchCategories() async {
    try {
      categories.value = await _productRepo.getCategories();
    } catch (_) {}
  }

  Future<void> _fetchFeatured() async {
    try {
      featuredProducts.value =
          await _productRepo.getProducts(isFeatured: true, limit: 10);
    } catch (_) {}
  }

  Future<void> _fetchFlashSales() async {
    try {
      flashSaleProducts.value =
          await _productRepo.getProducts(sortBy: 'discountedPrice', limit: 8);
    } catch (_) {}
  }
}
