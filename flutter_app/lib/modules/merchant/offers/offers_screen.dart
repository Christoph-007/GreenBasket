import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'offers_controller.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OffersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OffersController());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Offer', style: AppTextStyles.titleLarge),
        content: Text('Delete "$title"? This action cannot be undone.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteOffer(id);
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildOfferList(controller.activeOffers, canToggle: true),
            _buildOfferList(controller.scheduledOffers, canToggle: false),
            _buildOfferList(controller.expiredOffers,
                canToggle: false, isExpired: true),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/merchant/offers/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Offer', style: AppTextStyles.labelLarge),
      ),
    );
  }

  Widget _buildOfferList(
    RxList<Map<String, dynamic>> offers, {
    bool canToggle = true,
    bool isExpired = false,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 64, color: AppColors.textHint),
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
      itemBuilder: (ctx, i) => _buildOfferCard(
        offers[i],
        canToggle: canToggle,
        isExpired: isExpired,
      ),
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> offer, {
    bool canToggle = true,
    bool isExpired = false,
  }) {
    final id = offer['_id'] ?? offer['id'] ?? '';
    final title = offer['title'] ?? offer['name'] ?? 'Untitled Offer';
    final type = offer['type'] ?? offer['discountType'] ?? 'Percentage';
    final discountVal = offer['discount'] ?? offer['discountValue'] ?? 0;
    final discountDisplay = type == 'Fixed'
        ? '₹$discountVal off'
        : '$discountVal%';
    final validFrom = offer['validFrom'] ?? offer['startDate'] ?? '';
    final validTo = offer['validTo'] ?? offer['endDate'] ?? '';
    final usedCount = offer['used'] ?? offer['usedCount'] ?? 0;
    final limit = offer['limit'] ?? offer['usageLimit'] ?? 0;
    final isActive = offer['active'] == true || offer['status'] == 'active';
    final double usageRatio =
        limit > 0 ? (usedCount as num) / (limit as num) : 0.0;

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'Flash':
        typeColor = AppColors.error;
        typeIcon = Icons.flash_on;
        break;
      case 'Fixed':
        typeColor = AppColors.secondary;
        typeIcon = Icons.discount_outlined;
        break;
      default:
        typeColor = AppColors.primary;
        typeIcon = Icons.percent;
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
                          Text(title, style: AppTextStyles.titleMedium),
                          Text(type, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        discountDisplay,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: typeColor),
                      ),
                    ),
                  ],
                ),
                if (validFrom.isNotEmpty || validTo.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$validFrom – $validTo',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (limit > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage: $usedCount / $limit',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: usageRatio.toDouble(),
                          backgroundColor: AppColors.border,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(typeColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    onPressed: () => Get.toNamed('/merchant/offers/edit',
                        arguments: offer),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 20),
                    tooltip: 'Edit',
                  ),
                IconButton(
                  onPressed: () => _confirmDelete(id, title),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  tooltip: 'Delete',
                ),
                const Spacer(),
                if (canToggle)
                  Row(
                    children: [
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Switch(
                        value: isActive,
                        onChanged: (v) =>
                            controller.toggleOffer(id, v),
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
