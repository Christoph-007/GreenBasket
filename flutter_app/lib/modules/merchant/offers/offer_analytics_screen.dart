import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class OfferAnalyticsScreen extends StatelessWidget {
  const OfferAnalyticsScreen({super.key});

  // Mock redemption data — TODO: fetch from API using offer ID from Get.arguments
  static const _redemptions = [
    {
      'customer': 'Priya Sharma',
      'date': 'Mar 22, 10:30 AM',
      'orderValue': 480.0,
      'discount': 96.0,
    },
    {
      'customer': 'Rahul Gupta',
      'date': 'Mar 22, 09:15 AM',
      'orderValue': 320.0,
      'discount': 64.0,
    },
    {
      'customer': 'Anjali Mehta',
      'date': 'Mar 21, 06:45 PM',
      'orderValue': 590.0,
      'discount': 100.0,
    },
    {
      'customer': 'Vikram Singh',
      'date': 'Mar 21, 03:20 PM',
      'orderValue': 210.0,
      'discount': 42.0,
    },
    {
      'customer': 'Sunita Patel',
      'date': 'Mar 20, 11:10 AM',
      'orderValue': 440.0,
      'discount': 88.0,
    },
  ];

  // Bar chart data (weekly redemptions) — mock
  static const List<Map<String, dynamic>> _chartData = [
    {'day': 'Mon', 'count': 4},
    {'day': 'Tue', 'count': 7},
    {'day': 'Wed', 'count': 5},
    {'day': 'Thu', 'count': 12},
    {'day': 'Fri', 'count': 9},
    {'day': 'Sat', 'count': 15},
    {'day': 'Sun', 'count': 11},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offer Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.percent,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Summer Fresh Sale',
                            style: AppTextStyles.titleLarge),
                        const SizedBox(height: 2),
                        Text('20% off · All products',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text('Active',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(
                                          color: AppColors.success)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Mar 1 – Mar 31',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats row
            _buildStatsRow(),
            const SizedBox(height: AppSpacing.lg),

            // Chart
            Text('Daily Redemptions (This Week)',
                style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _buildBarChart(),
            const SizedBox(height: AppSpacing.lg),

            // Recent redemptions
            Text('Recent Redemptions', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ..._redemptions.map(_buildRedemptionCard),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total Uses', 'value': '48', 'icon': Icons.people_outline},
      {
        'label': 'Revenue',
        'value': '₹22.5K',
        'icon': Icons.currency_rupee
      },
      {
        'label': 'Avg Order',
        'value': '₹469',
        'icon': Icons.shopping_bag_outlined
      },
      {
        'label': 'Discount Given',
        'value': '₹4.5K',
        'icon': Icons.discount_outlined
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (ctx, i) {
        final stat = stats[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(stat['icon'] as IconData,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(stat['label'] as String,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(stat['value'] as String,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    final maxCount = _chartData
        .map((d) => d['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _chartData.map((d) {
                final ratio = (d['count'] as int) / maxCount;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${d['count']}',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.sm)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: _chartData.map((d) {
              return Expanded(
                child: Text(
                  d['day'] as String,
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              (r['customer'] as String)[0],
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['customer'] as String,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500)),
                Text(r['date'] as String, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(r['orderValue'] as double).toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium,
              ),
              Text(
                '-₹${(r['discount'] as double).toStringAsFixed(0)} off',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
