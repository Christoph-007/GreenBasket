import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class ReturnsAdminScreen extends StatefulWidget {
  const ReturnsAdminScreen({super.key});

  @override
  State<ReturnsAdminScreen> createState() => _ReturnsAdminScreenState();
}

class _ReturnsAdminScreenState extends State<ReturnsAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _refundController = TextEditingController();
  bool _approving = true;

  // Mock returns data — replace with API call
  final _returns = [
    {
      'id': 'RTN001',
      'orderId': 'GB2024089',
      'item': 'Organic Spinach 500g',
      'reason': 'Item was wilted and not fresh',
      'amount': '₹120',
      'status': 'Pending',
      'date': '20 Mar 2024',
      'tab': 0,
    },
    {
      'id': 'RTN002',
      'orderId': 'GB2024081',
      'item': 'Fresh Tomatoes 1kg',
      'reason': 'Received wrong item',
      'amount': '₹60',
      'status': 'Pending',
      'date': '19 Mar 2024',
      'tab': 0,
    },
    {
      'id': 'RTN003',
      'orderId': 'GB2024072',
      'item': 'Baby Carrots 250g',
      'reason': 'Damaged packaging',
      'amount': '₹45',
      'status': 'Processing',
      'date': '17 Mar 2024',
      'tab': 1,
    },
    {
      'id': 'RTN004',
      'orderId': 'GB2024060',
      'item': 'Organic Apples 1kg',
      'reason': 'Quality not as expected',
      'amount': '₹220',
      'status': 'Completed',
      'date': '14 Mar 2024',
      'tab': 2,
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Processing':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refundController.dispose();
    super.dispose();
  }

  void _showProcessDialog(Map<String, dynamic> ret) {
    _refundController.text = ret['amount'] as String;
    _approving = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: Text('Process Return #${ret['id']}', style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${ret['item']}', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Reason: ${ret['reason']}', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Approve'),
                      selected: _approving,
                      onSelected: (_) => setDialogState(() => _approving = true),
                      selectedColor: AppColors.success,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: _approving ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Reject'),
                      selected: !_approving,
                      onSelected: (_) => setDialogState(() => _approving = false),
                      selectedColor: AppColors.error,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: !_approving ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_approving) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _refundController,
                  decoration: const InputDecoration(
                    labelText: 'Refund Amount',
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _approving ? AppColors.success : AppColors.error,
              ),
              onPressed: () {
                // TODO: Call API to process return
                Navigator.pop(ctx);
                Get.snackbar(
                  _approving ? 'Return Approved' : 'Return Rejected',
                  'Return #${ret['id']} has been ${_approving ? 'approved. Refund of ${_refundController.text} will be processed.' : 'rejected.'}',
                  backgroundColor: _approving ? AppColors.success : AppColors.error,
                  colorText: Colors.white,
                );
              },
              child: Text(_approving ? 'Approve & Refund' : 'Reject'),
            ),
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
        title: const Text('Returns & Refunds'),
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
          _buildStats(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2].map((tab) {
                final list = _returns.where((r) => r['tab'] == tab).toList();
                return list.isEmpty
                    ? const Center(child: Text('No returns in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _buildReturnCard(list[i]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _statItem('Pending Returns', '2', Icons.pending_outlined, AppColors.warning),
          Container(width: 1, height: 48, color: AppColors.border),
          _statItem('Total Refunded', '₹4,320', Icons.currency_rupee, AppColors.success),
          Container(width: 1, height: 48, color: AppColors.border),
          _statItem('Avg. Processing', '2.4 days', Icons.schedule, AppColors.info),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildReturnCard(Map<String, dynamic> ret) {
    final status = ret['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${ret['id']}', style: AppTextStyles.titleMedium),
                const Spacer(),
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
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(ret['item'] as String, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('Order #${ret['orderId']} • ${ret['date']}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text(ret['reason'] as String, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Requested: ', style: AppTextStyles.bodySmall),
                      TextSpan(
                        text: ret['amount'] as String,
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                if (status == 'Pending')
                  ElevatedButton(
                    onPressed: () => _showProcessDialog(ret),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Process Return'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
