import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/common/gb_button.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/empty_state.dart';
import '../cart/cart_controller.dart';

class ProductDetailController extends GetxController {
  final _repo = ProductRepository();
  final isLoading = false.obs;
  final product = Rxn<ProductModel>();
  final selectedPreparationOption = Rxn<PreparationOption>();
  final quantity = 1.obs;
  final isInWishlist = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final id = args['productId'] as String? ?? '';
    if (id.isNotEmpty) fetchProduct(id);
  }

  Future<void> fetchProduct(String id) async {
    isLoading.value = true;
    try {
      product.value = await _repo.getProduct(id);
    } catch (_) {}
    isLoading.value = false;
  }

  void incrementQty() => quantity.value++;
  void decrementQty() {
    if (quantity.value > 1) quantity.value--;
  }

  void selectPreparation(PreparationOption? option) {
    selectedPreparationOption.value = option;
  }

  Future<void> toggleWishlist() async {
    if (product.value == null) return;
    try {
      if (isInWishlist.value) {
        await _repo.removeFromWishlist(product.value!.id);
      } else {
        await _repo.addToWishlist(product.value!.id);
      }
      isInWishlist.value = !isInWishlist.value;
    } catch (_) {}
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProductDetailController());
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (ctrl.isLoading.value) return const GBPageLoader();
        if (ctrl.product.value == null) {
          return const ErrorState(message: 'Product not found');
        }
        final product = ctrl.product.value!;
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Image gallery header
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.surface,
                  leading: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  actions: [
                    Obx(() => GestureDetector(
                          onTap: ctrl.toggleWishlist,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ctrl.isInWishlist.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: ctrl.isInWishlist.value
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        )),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: product.images.isNotEmpty
                        ? PageView.builder(
                            itemCount: product.images.length,
                            itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: product.images[i],
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            color: AppColors.primaryContainer,
                            child: const Icon(Icons.eco_outlined,
                                size: 80, color: AppColors.primary),
                          ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + badges
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(product.name,
                                  style: AppTextStyles.headlineLarge),
                            ),
                            if (product.isOrganic)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text('Organic',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.primary)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Rating
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: product.rating,
                              itemSize: 16,
                              itemBuilder: (_, __) =>
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.secondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Price
                        Row(
                          children: [
                            Text(
                              '₹${product.effectivePrice.toStringAsFixed(0)}/${product.unit}',
                              style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.primary),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textHint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  '${product.discountPercent}% OFF',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: AppColors.error),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${product.merchantName}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const Divider(height: 28),

                        // Description
                        Text('About this product',
                            style: AppTextStyles.titleLarge),
                        const SizedBox(height: 8),
                        Text(product.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),

                        // Preparation options
                        if (product.preparationOptions.isNotEmpty) ...[
                          const Divider(height: 28),
                          Text('Preparation Options',
                              style: AppTextStyles.titleLarge),
                          const SizedBox(height: 12),
                          Obx(() => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: product.preparationOptions
                                    .map((opt) => GestureDetector(
                                          onTap: () =>
                                              ctrl.selectPreparation(opt),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: ctrl.selectedPreparationOption
                                                          .value?.id ==
                                                      opt.id
                                                  ? AppColors.primary
                                                  : AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.full),
                                              border: Border.all(
                                                color: ctrl
                                                            .selectedPreparationOption
                                                            .value
                                                            ?.id ==
                                                        opt.id
                                                    ? AppColors.primary
                                                    : AppColors.border,
                                              ),
                                            ),
                                            child: Text(
                                              '${opt.name}${opt.additionalPrice > 0 ? ' +₹${opt.additionalPrice.toInt()}' : ''}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: ctrl
                                                            .selectedPreparationOption
                                                            .value
                                                            ?.id ==
                                                        opt.id
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              )),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Quantity
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: ctrl.decrementQty,
                            color: AppColors.textPrimary,
                          ),
                          Obx(() => Text(
                                ctrl.quantity.value.toString(),
                                style: AppTextStyles.titleLarge,
                              )),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: ctrl.incrementQty,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GBButton(
                        label: 'Add to Cart',
                        onPressed: () => cartCtrl.addItem(
                          productId: product.id,
                          quantity: ctrl.quantity.value,
                          preparationOption:
                              ctrl.selectedPreparationOption.value?.id,
                        ),
                        isFullWidth: true,
                        leadingIcon: Icons.shopping_cart_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
