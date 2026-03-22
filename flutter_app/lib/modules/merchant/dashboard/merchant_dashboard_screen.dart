import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/auth/auth_controller.dart';
import 'package:greenbasket_app/modules/merchant/merchant_controller.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  final controller = Get.put(MerchantController());

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
              _buildKPIs(),
              _buildNewOrders(),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning 👋',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    "Priya's Organic Store",
                    style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Text('PO', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 8),
                Obx(() => Text(
                      'Store Status: ${controller.isStoreOpen.value ? "Currently Open" : "Closed"}',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                    )),
                const Spacer(),
                Obx(() => Switch(
                      value: controller.isStoreOpen.value,
                      onChanged: controller.toggleStoreStatus,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.success,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _kpiCard('Today\'s Revenue', controller.revenue.value, Icons.payments_outlined, AppColors.primaryContainer),
          const SizedBox(width: AppSpacing.md),
          _kpiCard('Orders', '${controller.orderCount.value}', Icons.receipt_long_outlined, Colors.orange.shade50),
          const SizedBox(width: AppSpacing.md),
          _kpiCard('Rating', '${controller.rating.value}', Icons.star_outline, Colors.blue.shade50),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Orders', style: AppTextStyles.headlineLarge),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.newOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.newOrders[index];
                  return _orderCard(order);
                },
              )),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order['id']}', style: AppTextStyles.titleMedium),
                Text(order['time'], style: AppTextStyles.bodySmall),
              ],
            ),
            const Divider(height: 24),
            Text(order['customer'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(order['items'], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['amount'], style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Decline')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('Accept')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
