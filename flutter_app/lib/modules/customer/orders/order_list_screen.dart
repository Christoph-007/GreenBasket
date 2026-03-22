import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/empty_state.dart';

class OrderListController extends GetxController {
  final _repo = OrderRepository();
  final activeOrders = <OrderModel>[].obs;
  final pastOrders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final all = await _repo.getOrders();
      activeOrders.value = all.where((o) => o.isActive).toList();
      pastOrders.value = all.where((o) => !o.isActive).toList();
    } catch (_) {}
    isLoading.value = false;
  }
}

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OrderListController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('My Orders', style: AppTextStyles.titleLarge),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past Orders'),
            ],
          ),
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) return const GBLoader();
          return TabBarView(
            children: [
              _OrdersList(orders: ctrl.activeOrders, isActive: true),
              _OrdersList(orders: ctrl.pastOrders, isActive: false),
            ],
          );
        }),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isActive;
  const _OrdersList({required this.orders, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: isActive ? Icons.local_shipping_outlined : Icons.receipt_long_outlined,
        title: isActive ? 'No active orders' : 'No past orders',
        message: isActive
            ? 'Your active orders will appear here'
            : 'Your order history will appear here',
        actionLabel: isActive ? 'Start Shopping' : null,
        onAction: isActive ? () => Get.toNamed(Routes.categories) : null,
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => Get.find<OrderListController>().fetchOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: orders.length,
        itemBuilder: (context, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.orderDetail,
          arguments: {'orderId': order.id}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order #${order.orderNumber}',
                    style: AppTextStyles.titleMedium),
                const Spacer(),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'} • ${AppHelpers.formatCurrency(order.total)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              AppHelpers.formatDateTime(order.createdAt),
              style: AppTextStyles.bodySmall,
            ),
            if (order.isActive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppHelpers.getOrderStatusLabel(order.status),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    const Text('Track',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get color {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'preparing':
        return AppColors.secondary;
      case 'dispatched':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        AppHelpers.getOrderStatusLabel(status),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
