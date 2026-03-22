import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/auth/auth_controller.dart';
import 'package:greenbasket_app/modules/admin/admin_controller.dart';

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
      child: Row(
        children: [
          _statCard('Total Users', '${controller.totalUsers.value}', Icons.people_outline, Colors.blue.shade50),
          const SizedBox(width: AppSpacing.md),
          _statCard('Orders Today', '${controller.ordersToday.value}', Icons.shopping_basket_outlined, Colors.green.shade50),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color bgColor) {
    return Expanded(
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
    );
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _metricItem('Revenue', controller.revenue.value),
          _metricDivider(),
          _metricItem('Pending Actions', '${controller.pendingActions.value}'),
        ],
      ),
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
          Row(
            children: [
              _actionCard('${controller.merchantApprovals.value} Merchant Approvals', Colors.orange.shade100, Colors.orange),
              const SizedBox(width: AppSpacing.md),
              _actionCard('${controller.agentVerifications.value} Agent Verifications', Colors.blue.shade100, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String text, Color bgColor, Color iconColor) {
    return Expanded(
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
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.recentOrders[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Order #${order['id']}'),
                    subtitle: const Text('2 mins ago'),
                    trailing: _statusBadge(order['status'] as String, order['color'] as String),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, String colorType) {
    Color color;
    switch (colorType) {
      case 'success': color = AppColors.success; break;
      case 'warning': color = AppColors.warning; break;
      case 'info': color = AppColors.info; break;
      default: color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
