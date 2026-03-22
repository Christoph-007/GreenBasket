import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class MerchantAnalyticsScreen extends StatefulWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  State<MerchantAnalyticsScreen> createState() => _MerchantAnalyticsScreenState();
}

class _MerchantAnalyticsScreenState extends State<MerchantAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 1; // 0=Week, 1=Month, 2=Year

  // Mock data — replace with API call
  final _merchant = {
    'name': 'Fresh Farms Organics',
    'joinDate': '15 Jan 2024',
    'rating': '4.7',
  };

  final _stats = {
    'revenue': '₹1,24,500',
    'orders': '342',
    'products': '87',
    'avgRating': '4.7',
  };

  final _chartData = [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.65];
  final _chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _topProducts = [
    {'name': 'Organic Spinach 500g', 'sales': '124 sold', 'revenue': '₹12,400'},
    {'name': 'Fresh Tomatoes 1kg', 'sales': '98 sold', 'revenue': '₹9,800'},
    {'name': 'Baby Carrots 250g', 'sales': '76 sold', 'revenue': '₹5,700'},
  ];

  final _reviews = [
    {'author': 'Priya S.', 'rating': 5, 'comment': 'Always fresh and well-packaged!'},
    {'author': 'Amit K.', 'rating': 4, 'comment': 'Good quality, slightly delayed delivery.'},
    {'author': 'Neha R.', 'rating': 5, 'comment': 'Best organic store on the platform!'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() => setState(() => _selectedPeriod = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Merchant Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMerchantHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildStatsGrid(),
            const SizedBox(height: AppSpacing.md),
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.md),
            _buildRevenueChart(),
            const SizedBox(height: AppSpacing.md),
            _buildTopProducts(),
            const SizedBox(height: AppSpacing.md),
            _buildReviewsSummary(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.store, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_merchant['name']!, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 2),
                  Text('Joined ${_merchant['joinDate']}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 2),
                    Text(_merchant['rating']!, style: AppTextStyles.titleMedium),
                  ],
                ),
                Text('Rating', style: AppTextStyles.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      {'label': 'Total Revenue', 'value': _stats['revenue']!, 'icon': Icons.currency_rupee, 'color': AppColors.primary},
      {'label': 'Orders', 'value': _stats['orders']!, 'icon': Icons.shopping_bag_outlined, 'color': AppColors.info},
      {'label': 'Products', 'value': _stats['products']!, 'icon': Icons.inventory_2_outlined, 'color': AppColors.secondary},
      {'label': 'Avg Rating', 'value': _stats['avgRating']!, 'icon': Icons.star_outline, 'color': AppColors.warning},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['value'] as String, style: AppTextStyles.titleMedium),
                      Text(item['label'] as String, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.labelLarge,
        tabs: const [
          Tab(text: 'Week'),
          Tab(text: 'Month'),
          Tab(text: 'Year'),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Revenue', style: AppTextStyles.titleLarge),
                Text(
                  ['This Week', 'This Month', 'This Year'][_selectedPeriod],
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_chartData.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 100 * _chartData[i],
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.primaryLight, AppColors.primary],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_chartLabels[i], style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Products', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._topProducts.asMap().entries.map((e) {
              final i = e.key;
              final product = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['name']!, style: AppTextStyles.bodyMedium),
                              Text(product['sales']!, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(product['revenue']!, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Customer Reviews', style: AppTextStyles.titleLarge),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 2),
                    Text(_merchant['rating']!, style: AppTextStyles.titleMedium),
                    Text(' / 5.0', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._reviews.asMap().entries.map((e) {
              final i = e.key;
              final review = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(review['author'] as String, style: AppTextStyles.labelLarge),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (s) => Icon(
                                  s < (review['rating'] as int) ? Icons.star : Icons.star_border,
                                  color: AppColors.secondary,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(review['comment'] as String, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
