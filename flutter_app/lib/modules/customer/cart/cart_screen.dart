import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_button.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/gb_loader.dart';
import 'cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CartController>();
    final couponCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('My Cart', style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
        actions: [
          Obx(() => ctrl.items.isNotEmpty
              ? TextButton(
                  onPressed: () => _confirmClear(ctrl),
                  child: Text('Clear',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) return const GBLoader();
        if (ctrl.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: 'Add items to start shopping',
            actionLabel: 'Browse Products',
            onAction: () => Get.toNamed(Routes.categories),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: ctrl.items.length,
                itemBuilder: (context, i) {
                  final item = ctrl.items[i];
                  return _CartItemTile(item: item, cartCtrl: ctrl);
                },
              ),
            ),

            // Coupon + summary
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coupon input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponCtrl,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            hintStyle: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textHint),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GBButton(
                        label: 'Apply',
                        onPressed: () =>
                            ctrl.applyCoupon(couponCtrl.text.trim()),
                        height: 44,
                      ),
                    ],
                  ),
                  Obx(() {
                    if (ctrl.appliedCoupon.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Coupon "${ctrl.appliedCoupon.value}" applied',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.success),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: ctrl.clearCoupon,
                            child: Text('Remove',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),

                  // Price breakdown
                  Obx(() => Column(
                        children: [
                          _PriceLine('Subtotal',
                              AppHelpers.formatCurrency(ctrl.subtotal)),
                          const SizedBox(height: 6),
                          _PriceLine(
                            'Delivery Fee',
                            ctrl.deliveryFee == 0
                                ? 'FREE'
                                : AppHelpers.formatCurrency(ctrl.deliveryFee),
                            valueColor: ctrl.deliveryFee == 0
                                ? AppColors.success
                                : null,
                          ),
                          if (ctrl.discount.value > 0) ...[
                            const SizedBox(height: 6),
                            _PriceLine(
                              'Discount',
                              '-${AppHelpers.formatCurrency(ctrl.discount.value)}',
                              valueColor: AppColors.success,
                            ),
                          ],
                          const Divider(height: 16),
                          _PriceLine(
                            'Total',
                            AppHelpers.formatCurrency(ctrl.total),
                            isBold: true,
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
                  GBButton(
                    label: 'Proceed to Checkout',
                    onPressed: () => Get.toNamed(Routes.checkout),
                    isFullWidth: true,
                    leadingIcon: Icons.shopping_bag_outlined,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _confirmClear(CartController ctrl) {
    Get.defaultDialog(
      title: 'Clear Cart',
      middleText: 'Are you sure you want to remove all items?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        // ctrl.clearCart();
        Get.back();
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final CartController cartCtrl;
  const _CartItemTile({required this.item, required this.cartCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: item.productImage != null
                ? CachedNetworkImage(
                    imageUrl: item.productImage!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: AppColors.primaryContainer,
                    child: const Icon(Icons.eco_outlined,
                        color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(item.merchantName, style: AppTextStyles.bodySmall),
                if (item.preparationOption != null)
                  Text(item.preparationOption!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      AppHelpers.formatCurrency(item.itemTotal),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    // Quantity controls
                    _QtyControl(
                      quantity: item.quantity,
                      onDecrement: () => cartCtrl.updateQuantity(
                          item.productId, item.quantity - 1),
                      onIncrement: () => cartCtrl.updateQuantity(
                          item.productId, item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QtyControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                quantity <= 1 ? Icons.delete_outline : Icons.remove,
                size: 16,
                color: quantity <= 1 ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$quantity', style: AppTextStyles.titleMedium),
          ),
          InkWell(
            onTap: onIncrement,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _PriceLine(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final style = isBold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ?? (isBold ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }
}
