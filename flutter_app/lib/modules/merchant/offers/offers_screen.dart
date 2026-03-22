import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data — TODO: fetch from API
  final List<Map<String, dynamic>> _activeOffers = [
    {
      'title': 'Summer Fresh Sale',
      'type': 'Percentage',
      'discount': '20%',
      'validFrom': 'Mar 1',
      'validTo': 'Mar 31',
      'used': 48,
      'limit': 100,
      'active': true,
    },
    {
      'title': 'First Order Bonus',
      'type': 'Fixed',
      'discount': '₹50 off',
      'validFrom': 'Jan 1',
      'validTo': 'Dec 31',
      'used': 125,
      'limit': 500,
      'active': true,
    },
  ];

  final List<Map<String, dynamic>> _scheduledOffers = [
    {
      'title': 'Holi Special',
      'type': 'Percentage',
      'discount': '15%',
      'validFrom': 'Mar 25',
      'validTo': 'Mar 26',
      'used': 0,
      'limit': 200,
      'active': false,
    },
  ];

  final List<Map<String, dynamic>> _expiredOffers = [
    {
      'title': 'Republic Day Offer',
      'type': 'Percentage',
      'discount': '26%',
      'validFrom': 'Jan 25',
      'validTo': 'Jan 27',
      'used': 89,
      'limit': 100,
      'active': false,
    },
    {
      'title': 'New Year Bonanza',
      'type': 'Flash',
      'discount': '30%',
      'validFrom': 'Jan 1',
      'validTo': 'Jan 2',
      'used': 212,
      'limit': 250,
      'active': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteOffer(int index, List<Map<String, dynamic>> list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Offer', style: AppTextStyles.titleLarge),
        content: Text('This offer will be permanently deleted.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => list.removeAt(index));
              Navigator.pop(ctx);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offers & Discounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfferList(_activeOffers, canToggle: true),
          _buildOfferList(_scheduledOffers, canToggle: false),
          _buildOfferList(_expiredOffers, canToggle: false, isExpired: true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Get.toNamed('/merchant/offers/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Offer',
            style: AppTextStyles.labelLarge),
      ),
    );
  }

  Widget _buildOfferList(
    List<Map<String, dynamic>> offers, {
    bool canToggle = true,
    bool isExpired = false,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isExpired ? 'No expired offers' : 'No offers yet',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isExpired
                  ? 'Your expired offers will appear here'
                  : 'Create your first offer to attract customers',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: offers.length,
      itemBuilder: (ctx, i) =>
          _buildOfferCard(offers, i, canToggle: canToggle, isExpired: isExpired),
    );
  }

  Widget _buildOfferCard(
    List<Map<String, dynamic>> list,
    int index, {
    bool canToggle = true,
    bool isExpired = false,
  }) {
    final offer = list[index];
    final double usageRatio =
        (offer['limit'] as int) > 0
            ? (offer['used'] as int) / (offer['limit'] as int)
            : 0;

    Color typeColor;
    IconData typeIcon;
    switch (offer['type'] as String) {
      case 'Percentage':
        typeColor = AppColors.primary;
        typeIcon = Icons.percent;
        break;
      case 'Flash':
        typeColor = AppColors.error;
        typeIcon = Icons.flash_on;
        break;
      default:
        typeColor = AppColors.secondary;
        typeIcon = Icons.discount_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isExpired ? AppColors.border : typeColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offer['title'] as String,
                              style: AppTextStyles.titleMedium),
                          Text(offer['type'] as String,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        offer['discount'] as String,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: typeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${offer['validFrom']} – ${offer['validTo']}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usage: ${offer['used']} / ${offer['limit']}',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            child: LinearProgressIndicator(
                              value: usageRatio,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  typeColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Row(
              children: [
                if (!isExpired)
                  IconButton(
                    onPressed: () =>
                        Get.toNamed('/merchant/offers/edit',
                            arguments: offer),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 20),
                    tooltip: 'Edit',
                  ),
                IconButton(
                  onPressed: () => _deleteOffer(index, list),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  tooltip: 'Delete',
                ),
                const Spacer(),
                if (canToggle)
                  Row(
                    children: [
                      Text(
                        offer['active'] as bool ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: offer['active'] as bool
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Switch(
                        value: offer['active'] as bool,
                        onChanged: (v) =>
                            setState(() => list[index]['active'] = v),
                        activeColor: AppColors.primary,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
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
