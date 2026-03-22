import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/cards/product_card.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../cart/cart_controller.dart';

class CategoriesController extends GetxController {
  final _repo = ProductRepository();

  final isLoading = false.obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategoryId = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final preselected = args['categoryId'] as String? ?? '';
    fetchCategories(preselected: preselected);
  }

  Future<void> fetchCategories({String preselected = ''}) async {
    try {
      categories.value = await _repo.getCategories();
      if (preselected.isNotEmpty) {
        selectedCategoryId.value = preselected;
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
      if (selectedCategoryId.value.isNotEmpty) {
        fetchProducts(selectedCategoryId.value);
      }
    } catch (_) {}
  }

  Future<void> fetchProducts(String categoryId) async {
    isLoading.value = true;
    selectedCategoryId.value = categoryId;
    try {
      products.value = await _repo.getProducts(categoryId: categoryId);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    isLoading.value = true;
    searchQuery.value = query;
    try {
      products.value = await _repo.search(query);
    } catch (_) {}
    isLoading.value = false;
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CategoriesController());
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text('Categories', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed(Routes.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Row(
        children: [
          // Left: category list
          Container(
            width: 100,
            color: AppColors.surface,
            child: Obx(() => ListView.builder(
                  itemCount: ctrl.categories.length,
                  itemBuilder: (context, i) {
                    final cat = ctrl.categories[i];
                    final isSelected = ctrl.selectedCategoryId.value == cat.id;
                    return GestureDetector(
                      onTap: () => ctrl.fetchProducts(cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : Colors.transparent,
                          border: isSelected
                              ? const Border(
                                  left: BorderSide(
                                      color: AppColors.primary, width: 3))
                              : null,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: cat.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: cat.image!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.eco_outlined,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      size: 20),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),

          // Right: products grid
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const GBLoader();
              }
              if (ctrl.products.isEmpty) {
                return const EmptyState(
                  icon: Icons.eco_outlined,
                  title: 'No products found',
                  message: 'Try selecting a different category',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemCount: ctrl.products.length,
                itemBuilder: (context, i) {
                  final product = ctrl.products[i];
                  return ProductCard(
                    product: product,
                    onAddToCart: () =>
                        cartCtrl.addItem(productId: product.id, quantity: 1),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
