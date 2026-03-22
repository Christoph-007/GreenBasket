import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/admin_controller.dart';
import 'package:greenbasket_app/modules/admin/users/admin_users_screen.dart';
import 'package:greenbasket_app/modules/admin/orders/admin_orders_screen.dart';
import 'package:greenbasket_app/modules/admin/orders/admin_order_detail_screen.dart';
import 'package:greenbasket_app/modules/admin/merchants/admin_merchants_screen.dart';
import 'package:greenbasket_app/modules/admin/agents/admin_agents_screen.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildOverviewStats(),
              _buildMetrics(),
              _buildPendingActions(),
              _buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Text(
                    'Admin Dashboard',
                    style: AppTextStyles.displayMedium,
                  ),
                ],
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Text('SA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Obx(() => Row(
        children: [
          _statCard('Total Users', '${controller.totalUsersCount.value}', Icons.people_outline, Colors.blue.shade50, onTap: () {
            Get.to(() => const AdminUsersScreen());
          }),
          const SizedBox(width: AppSpacing.md),
          _statCard('Orders Today', '${controller.totalOrdersCount.value}', Icons.shopping_basket_outlined, Colors.green.shade50, onTap: () {
            Get.to(() => const AdminOrdersScreen());
          }),
        ],
      )),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color bgColor, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.textPrimary),
                const SizedBox(height: 12),
                Text(value, style: AppTextStyles.displaySmall),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Obx(() => Row(
        children: [
          _metricItem('Revenue', controller.revenueValue.value),
          _metricDivider(),
          _metricItem('Pending Actions', '${controller.pendingActionsCount.value}'),
        ],
      )),
    );
  }

  Widget _metricItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }

  Widget _buildPendingActions() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pending Actions', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              _actionCard('${controller.merchantApprovalsCount.value} Merchant Approvals', Colors.orange.shade100, Colors.orange, onTap: () {
                Get.to(() => const AdminMerchantsScreen());
              }),
              const SizedBox(width: AppSpacing.md),
              _actionCard('${controller.agentVerificationsCount.value} Agent Verifications', Colors.blue.shade100, Colors.blue, onTap: () {
                Get.to(() => const AdminAgentsScreen());
              }),
            ],
          )),
        ],
      ),
    );
  }

  Widget _actionCard(String text, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.report_gmailerrorred, color: iconColor),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: Colors.black))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders', style: AppTextStyles.titleLarge),
              TextButton(onPressed: () {
                Get.to(() => const AdminOrdersScreen());
              }, child: const Text('View All')),
            ],
          ),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentOrdersList.length,
                itemBuilder: (context, index) {
                  final order = controller.recentOrdersList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Order #${order['orderNumber'] ?? order['id']}'),
                    subtitle: Text(order['createdAt'] != null ? 'Just now' : '2 mins ago'),
                    trailing: _statusBadge(order['status'] as String? ?? 'Pending', 'info'),
                    onTap: () {
                      Get.to(() => AdminOrderDetailScreen(orderId: order['_id'] ?? order['id']));
                    },
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, String colorType) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered': color = AppColors.success; break;
      case 'pending': color = AppColors.warning; break;
      case 'preparing': color = AppColors.info; break;
      default: color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status.capitalizeFirst ?? '', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
