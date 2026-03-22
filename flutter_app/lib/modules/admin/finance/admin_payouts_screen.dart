import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock payouts — replace with API call
  final List<Map<String, dynamic>> _payouts = [
    {
      'id': 'PAY001',
      'merchant': 'Fresh Farms Organics',
      'amount': '₹28,450',
      'bankLast4': '4523',
      'requestDate': '20 Mar 2024',
      'status': 'Pending',
      'tab': 0,
    },
    {
      'id': 'PAY002',
      'merchant': 'Green Grocers',
      'amount': '₹15,200',
      'bankLast4': '8901',
      'requestDate': '20 Mar 2024',
      'status': 'Pending',
      'tab': 0,
    },
    {
      'id': 'PAY003',
      'merchant': 'Organic World',
      'amount': '₹42,800',
      'bankLast4': '2234',
      'requestDate': '19 Mar 2024',
      'status': 'Processing',
      'tab': 1,
    },
    {
      'id': 'PAY004',
      'merchant': 'Farm Fresh',
      'amount': '₹9,600',
      'bankLast4': '5567',
      'requestDate': '18 Mar 2024',
      'status': 'Completed',
      'tab': 2,
    },
    {
      'id': 'PAY005',
      'merchant': 'Nature Basket',
      'amount': '₹21,000',
      'bankLast4': '7789',
      'requestDate': '17 Mar 2024',
      'status': 'Completed',
      'tab': 2,
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Processing':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }

  List<Map<String, dynamic>> _payoutsForTab(int tab) {
    return _payouts.where((p) => p['tab'] == tab).toList().cast<Map<String, dynamic>>();
  }

  void _showProcessDialog(Map<String, dynamic> payout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Process Payout?', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merchant: ${payout['merchant']}', style: AppTextStyles.bodyMedium),
            Text('Amount: ${payout['amount']}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
            Text('Bank Account ending ****${payout['bankLast4']}', style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to process payout
              setState(() => payout['status'] = 'Processing');
              Navigator.pop(ctx);
              Get.snackbar('Payout Initiated',
                  'Payout of ${payout['amount']} to ${payout['merchant']} is being processed.',
                  backgroundColor: AppColors.success, colorText: Colors.white);
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showBulkProcessDialog() {
    final pending = _payoutsForTab(0);
    if (pending.isEmpty) return;
    final totalAmount = '₹${pending.length * 20000}'; // Mock total
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Bulk Process Payouts?', style: AppTextStyles.titleLarge),
        content: Text(
          'Process all ${pending.length} pending payouts (approx. $totalAmount total)?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to bulk process payouts
              Navigator.pop(ctx);
              Get.snackbar('Bulk Processing', 'All pending payouts are being processed.',
                  backgroundColor: AppColors.success, colorText: Colors.white);
            },
            child: const Text('Process All'),
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
        title: const Text('Merchant Payouts'),
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
            Tab(text: 'Pending'),
            Tab(text: 'Processing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPendingBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2].map((tab) {
                final payouts = _payoutsForTab(tab);
                return payouts.isEmpty
                    ? const Center(child: Text('No payouts in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: payouts.length,
                        itemBuilder: (_, i) => _buildPayoutCard(payouts[i]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    final pending = _payoutsForTab(0);
    return Container(
      color: AppColors.warning.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Pending: ₹43,650', style: AppTextStyles.titleMedium.copyWith(color: AppColors.warning)),
                Text('${pending.length} payout requests awaiting', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showBulkProcessDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Process All', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> payout) {
    final status = payout['status'] as String;
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payout['merchant'] as String, style: AppTextStyles.titleMedium),
                      Text('Bank ****${payout['bankLast4']}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSmall.copyWith(color: _statusColor(status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: AppTextStyles.bodySmall),
                    Text(payout['amount'] as String, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Requested', style: AppTextStyles.bodySmall),
                    Text(payout['requestDate'] as String, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ],
            ),
            if (status == 'Pending') ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showProcessDialog(payout),
                  child: const Text('Process Payout'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
