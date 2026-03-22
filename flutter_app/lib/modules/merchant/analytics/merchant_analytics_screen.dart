import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/utils/helpers.dart';
import 'merchant_analytics_controller.dart';
import '../financial/financial_screen.dart';
import '../financial/payouts_screen.dart';
import '../offers/offer_analytics_screen.dart';
import '../widgets/merchant_drawer.dart';

class MerchantAnalyticsScreen extends StatelessWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantAnalyticsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: const MerchantDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.monthlyOverview.value ?? {};

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month\'s Overview',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(AppHelpers.formatCurrency((data['revenue'] ?? 0).toDouble()),
                        style: AppTextStyles.headlineLarge
                            .copyWith(color: AppColors.primary, fontSize: 32)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildQuickStat('Sales', '${data['salesCount'] ?? 0}',
                            Icons.trending_up, AppColors.success),
                        const SizedBox(width: AppSpacing.lg),
                        Container(height: 40, width: 1, color: AppColors.border),
                        const SizedBox(width: AppSpacing.lg),
                        _buildQuickStat(
                            'Visitors',
                            '${data['visitorsCount'] ?? 0}',
                            Icons.visibility,
                            Colors.blue),
                        const SizedBox(width: AppSpacing.lg),
                        Container(height: 40, width: 1, color: AppColors.border),
                        const SizedBox(width: AppSpacing.lg),
                        _buildQuickStat(
                            'Conv. Rate',
                            '${data['conversionRate'] ?? 0}%',
                            Icons.data_usage,
                            Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text('Detailed Reports', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _analyticsCard(
                      context,
                      'Financial Overview',
                      'View revenue, sales history, and total earnings separated by days.',
                      Icons.account_balance_wallet,
                      AppColors.primary,
                      () => Get.to(() => const FinancialScreen()),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _analyticsCard(
                      context,
                      'Offer Analytics',
                      'Analyze how well your discounts are bringing in customers.',
                      Icons.bar_chart,
                      Colors.orange,
                      () => Get.to(() => const OfferAnalyticsScreen()),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _analyticsCard(
                      context,
                      'Store Payouts',
                      'Check your pending and past payouts directed to your bank account.',
                      Icons.payments,
                      AppColors.success,
                      () => Get.to(() => const PayoutsScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _analyticsCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_forward_ios,
                      color: AppColors.textHint, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}