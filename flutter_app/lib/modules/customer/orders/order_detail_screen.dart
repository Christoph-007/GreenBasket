import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/empty_state.dart';

class OrderDetailController extends GetxController {
  final _repo = OrderRepository();
  final isLoading = false.obs;
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final id = args['orderId'] as String? ?? '';
    if (id.isNotEmpty) fetchOrder(id);
  }

  Future<void> fetchOrder(String id) async {
    isLoading.value = true;
    try {
      order.value = await _repo.getOrder(id);
    } catch (_) {}
    isLoading.value = false;
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  static const _steps = [
    'pending',
    'confirmed',
    'preparing',
    'dispatched',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OrderDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'Order Details'),
      body: Obx(() {
        if (ctrl.isLoading.value) return const GBPageLoader();
        if (ctrl.order.value == null) {
          return const ErrorState(message: 'Order not found');
        }
        final order = ctrl.order.value!;
        final currentStep = _steps.indexOf(order.status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Order #${order.orderNumber}',
                            style: AppTextStyles.titleLarge),
                        const Spacer(),
                        _statusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(AppHelpers.formatDateTime(order.createdAt),
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status timeline
              if (order.status != 'cancelled') ...[
                Text('Order Timeline', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (i) {
                      final isDone = i <= currentStep;
                      final isCurrent = i == currentStep;
                      final isLast = i == _steps.length - 1;
                      return _TimelineStep(
                        label: AppHelpers.getOrderStatusLabel(_steps[i]),
                        isDone: isDone,
                        isCurrent: isCurrent,
                        isLast: isLast,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Delivery agent
              if (order.deliveryAgentName != null) ...[
                Text('Delivery Agent', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(order.deliveryAgentName!,
                            style: AppTextStyles.titleMedium),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_outlined,
                            color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Items
              Text('Items Ordered', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemCount: order.items.length,
                  itemBuilder: (context, i) {
                    final item = order.items[i];
                    return Row(
                      children: [
                        if (item.productImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.productImage!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.eco_outlined,
                                color: AppColors.primary),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: AppTextStyles.titleMedium),
                              Text('x${item.quantity}',
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrency(item.itemTotal),
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Delivery address
              Text('Delivery Address', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.deliveryAddress.label,
                              style: AppTextStyles.titleMedium),
                          Text(order.deliveryAddress.fullAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Price summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    _PriceRow('Subtotal', AppHelpers.formatCurrency(order.subtotal)),
                    const SizedBox(height: 8),
                    _PriceRow('Delivery Fee',
                        AppHelpers.formatCurrency(order.deliveryFee)),
                    if (order.discount > 0) ...[
                      const SizedBox(height: 8),
                      _PriceRow('Discount',
                          '-${AppHelpers.formatCurrency(order.discount)}',
                          color: AppColors.success),
                    ],
                    const Divider(height: 16),
                    _PriceRow('Total', AppHelpers.formatCurrency(order.total),
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button for eligible orders
              if (['pending', 'confirmed'].contains(order.status))
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Cancel Order'),
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'delivered':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        AppHelpers.getOrderStatusLabel(status),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDone ? AppColors.textPrimary : AppColors.textHint,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(
                color: color ?? (bold ? AppColors.primary : null))),
      ],
    );
  }
}
