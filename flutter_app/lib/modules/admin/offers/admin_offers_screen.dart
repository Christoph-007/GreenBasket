import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock platform offers — replace with API call
  final _platformOffers = [
    {
      'id': 'OFF001',
      'title': 'First Order Discount',
      'discount': '20% OFF',
      'merchant': null,
      'validity': 'Ongoing',
      'used': 342,
      'limit': 1000,
      'status': 'Active',
    },
    {
      'id': 'OFF002',
      'title': 'Weekend Special',
      'discount': '15% OFF',
      'merchant': null,
      'validity': '22-24 Mar 2024',
      'used': 128,
      'limit': 500,
      'status': 'Active',
    },
    {
      'id': 'OFF003',
      'title': 'Summer Sale',
      'discount': '₹100 OFF',
      'merchant': null,
      'validity': 'Expired 15 Mar',
      'used': 890,
      'limit': 1000,
      'status': 'Inactive',
    },
  ];

  final _merchantOffers = [
    {
      'id': 'MOF001',
      'title': 'Fresh Farms Flash Sale',
      'discount': '10% OFF',
      'merchant': 'Fresh Farms Organics',
      'validity': '20-25 Mar 2024',
      'used': 56,
      'limit': 200,
      'status': 'Active',
    },
    {
      'id': 'MOF002',
      'title': 'Buy 2 Get 1 Free',
      'discount': 'B2G1',
      'merchant': 'Green Grocers',
      'validity': '18-22 Mar 2024',
      'used': 34,
      'limit': 100,
      'status': 'Active',
    },
  ];

  Color _statusColor(String status) {
    return status == 'Active' ? AppColors.success : AppColors.textSecondary;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOfferOptions(Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(offer['title'] as String, style: AppTextStyles.titleLarge),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.info),
              title: const Text('Edit Offer'),
              onTap: () {
                // TODO: Navigate to edit offer screen
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                offer['status'] == 'Active' ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: AppColors.warning,
              ),
              title: Text(offer['status'] == 'Active' ? 'Deactivate' : 'Activate'),
              onTap: () {
                setState(() {
                  offer['status'] = offer['status'] == 'Active' ? 'Inactive' : 'Active';
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Offer', style: TextStyle(color: AppColors.error)),
              onTap: () {
                // TODO: Call API to delete offer
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offers & Promotions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Platform-wide'),
            Tab(text: 'Merchant Offers'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create platform offer screen
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Offer', style: TextStyle(color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOffersList(_platformOffers.cast<Map<String, dynamic>>()),
          _buildOffersList(_merchantOffers.cast<Map<String, dynamic>>()),
        ],
      ),
    );
  }

  Widget _buildOffersList(List<Map<String, dynamic>> offers) {
    return offers.isEmpty
        ? const Center(child: Text('No offers found.'))
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: offers.length,
            itemBuilder: (_, i) => _buildOfferCard(offers[i]),
          );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final status = offer['status'] as String;
    final used = offer['used'] as int;
    final limit = offer['limit'] as int;
    final usagePercent = used / limit;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    offer['discount'] as String,
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(offer['title'] as String, style: AppTextStyles.titleMedium)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSmall.copyWith(color: _statusColor(status)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                  onPressed: () => _showOfferOptions(offer),
                ),
              ],
            ),
            if (offer['merchant'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.store_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(offer['merchant'] as String, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(offer['validity'] as String, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usage: $used / $limit', style: AppTextStyles.bodySmall),
                Text('${(usagePercent * 100).toInt()}%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ],
        ),
      ),
    );
  }
}
