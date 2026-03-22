import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_button.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/gb_loader.dart';
import '../cart/cart_controller.dart';

class CheckoutController extends GetxController {
  final _repo = OrderRepository();
  final isLoading = false.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rxn<AddressModel>();
  final selectedPayment = 'cod'.obs;

  final paymentMethods = [
    {'id': 'cod', 'label': 'Cash on Delivery', 'icon': Icons.money},
    {'id': 'stripe', 'label': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'id': 'wallet', 'label': 'GreenBasket Wallet', 'icon': Icons.account_balance_wallet_outlined},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      addresses.value = await _repo.getAddresses();
      selectedAddress.value =
          addresses.firstWhereOrNull((a) => a.isDefault) ??
              addresses.firstOrNull;
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> placeOrder() async {
    if (selectedAddress.value == null) {
      Get.snackbar('Select Address',
          'Please select a delivery address before placing order',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final cartCtrl = Get.find<CartController>();
      final result = await _repo.checkout(
        addressId: selectedAddress.value!.id,
        paymentMethod: selectedPayment.value,
        couponCode: cartCtrl.appliedCoupon.value.isNotEmpty
            ? cartCtrl.appliedCoupon.value
            : null,
      );
      if (result['success'] == true) {
        await cartCtrl.fetchCart();
        Get.offAllNamed(Routes.orderList);
        Get.snackbar(
          'Order Placed!',
          'Your order has been placed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to place order',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to place order. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CheckoutController());
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'Checkout'),
      body: Obx(() {
        if (ctrl.isLoading.value) return const GBLoader();
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery address
                    Text('Delivery Address', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    if (ctrl.addresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off_outlined,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('No address saved',
                                  style: AppTextStyles.bodyMedium),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(Routes.addresses),
                              child: const Text('Add Address'),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...ctrl.addresses.map((addr) => Obx(() => GestureDetector(
                                onTap: () => ctrl.selectedAddress.value = addr,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                      color: ctrl.selectedAddress.value?.id ==
                                              addr.id
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: ctrl.selectedAddress.value?.id ==
                                              addr.id
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        addr.label == 'Home'
                                            ? Icons.home_outlined
                                            : Icons.work_outline,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(addr.label,
                                                style: AppTextStyles.titleMedium),
                                            Text(addr.fullAddress,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                        color: AppColors
                                                            .textSecondary),
                                                maxLines: 2),
                                          ],
                                        ),
                                      ),
                                      if (ctrl.selectedAddress.value?.id ==
                                          addr.id)
                                        const Icon(Icons.check_circle,
                                            color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ))),
                          TextButton.icon(
                            onPressed: () => Get.toNamed(Routes.addresses),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add new address'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Payment method
                    Text('Payment Method', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    ...ctrl.paymentMethods.map((method) => Obx(() => GestureDetector(
                          onTap: () => ctrl.selectedPayment.value =
                              method['id'] as String,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: ctrl.selectedPayment.value ==
                                        method['id']
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: ctrl.selectedPayment.value ==
                                        method['id']
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(method['icon'] as IconData,
                                    color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(method['label'] as String,
                                      style: AppTextStyles.titleMedium),
                                ),
                                if (ctrl.selectedPayment.value == method['id'])
                                  const Icon(Icons.check_circle,
                                      color: AppColors.primary),
                              ],
                            ),
                          ),
                        ))),
                    const SizedBox(height: 24),

                    // Order summary
                    Text('Order Summary', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Obx(() => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            children: [
                              _Row('Subtotal',
                                  AppHelpers.formatCurrency(cartCtrl.subtotal)),
                              const SizedBox(height: 8),
                              _Row(
                                'Delivery Fee',
                                cartCtrl.deliveryFee == 0
                                    ? 'FREE'
                                    : AppHelpers.formatCurrency(
                                        cartCtrl.deliveryFee),
                              ),
                              if (cartCtrl.discount.value > 0) ...[
                                const SizedBox(height: 8),
                                _Row(
                                  'Coupon Discount',
                                  '-${AppHelpers.formatCurrency(cartCtrl.discount.value)}',
                                  valueColor: AppColors.success,
                                ),
                              ],
                              const Divider(height: 16),
                              _Row(
                                'Total',
                                AppHelpers.formatCurrency(cartCtrl.total),
                                isBold: true,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Place order button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, -2))
                ],
              ),
              child: Obx(() => GBButton(
                    label: 'Place Order — ${AppHelpers.formatCurrency(cartCtrl.total)}',
                    onPressed: ctrl.placeOrder,
                    isLoading: ctrl.isLoading.value,
                    isFullWidth: true,
                  )),
            ),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final style = isBold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(
                color: valueColor ?? (isBold ? AppColors.primary : null))),
      ],
    );
  }
}
