import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  const AdminOrderDetailScreen({super.key});

  // Mock order data — replace with API call
  static const _order = {
    'id': 'GB2024001',
    'status': 'Out for Delivery',
    'statusIndex': 3,
    'customer': {'name': 'Priya Sharma', 'phone': '+91 98765 43210', 'address': '42 MG Road, Koramangala, Bangalore - 560034'},
    'merchant': {'name': 'Fresh Farms Organics', 'phone': '+91 87654 32109'},
    'agent': {'name': 'Ravi Kumar', 'phone': '+91 76543 21098', 'vehicle': 'Two-wheeler'},
  };

  static final _items = [
    {'name': 'Organic Spinach 500g', 'qty': 2, 'price': '₹120'},
    {'name': 'Fresh Tomatoes 1kg', 'qty': 1, 'price': '₹60'},
    {'name': 'Baby Carrots 250g', 'qty': 3, 'price': '₹45'},
  ];

  static final _activityLog = [
    {'time': '10:32 AM', 'event': 'Order placed by Priya Sharma', 'date': 'Today'},
    {'time': '10:35 AM', 'event': 'Order confirmed by Fresh Farms Organics', 'date': 'Today'},
    {'time': '11:00 AM', 'event': 'Order preparation started', 'date': 'Today'},
    {'time': '11:45 AM', 'event': 'Order picked up by Ravi Kumar', 'date': 'Today'},
  ];

  static const _statuses = ['Placed', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered'];

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      case 'Out for Delivery':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  void _showActionDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('$action?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to $action order #${_order['id']}? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Cancel Order' ? AppColors.error : AppColors.primary,
            ),
            onPressed: () {
              // TODO: Call API to perform action
              Navigator.pop(ctx);
              Get.snackbar('Action Taken', '$action has been applied to order #${_order['id']}.',
                  backgroundColor: AppColors.primary, colorText: Colors.white);
            },
            child: const Text('Confirm'),
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
        title: Text('Order #${_order['id']}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(_order['status'] as String).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _order['status'] as String,
              style: AppTextStyles.labelSmall.copyWith(
                color: _statusColor(_order['status'] as String),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeline(),
            const SizedBox(height: AppSpacing.md),
            _buildCustomerCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildMerchantCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildAgentCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildItemsList(),
            const SizedBox(height: AppSpacing.md),
            _buildAdminActions(context),
            const SizedBox(height: AppSpacing.md),
            _buildActivityLog(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final currentIndex = _order['statusIndex'] as int;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Status', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: List.generate(_statuses.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIndex = i ~/ 2;
                  final isPast = stepIndex < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: isPast ? AppColors.primary : AppColors.border,
                    ),
                  );
                } else {
                  final stepIndex = i ~/ 2;
                  final isDone = stepIndex <= currentIndex;
                  return Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primary : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: isDone ? 16 : 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statuses[stepIndex],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDone ? AppColors.primary : AppColors.textHint,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> rows,
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.titleMedium),
                if (trailing != null) ...[const Spacer(), trailing],
              ],
            ),
            const Divider(height: AppSpacing.md),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(row['label']!, style: AppTextStyles.bodySmall),
                      ),
                      Expanded(child: Text(row['value']!, style: AppTextStyles.bodyMedium)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    final c = _order['customer'] as Map<String, String>;
    return _buildInfoCard(
      title: 'Customer',
      icon: Icons.person_outline,
      iconColor: AppColors.info,
      rows: [
        {'label': 'Name', 'value': c['name']!},
        {'label': 'Phone', 'value': c['phone']!},
        {'label': 'Address', 'value': c['address']!},
      ],
    );
  }

  Widget _buildMerchantCard() {
    final m = _order['merchant'] as Map<String, String>;
    return _buildInfoCard(
      title: 'Merchant',
      icon: Icons.store_outlined,
      iconColor: AppColors.primary,
      rows: [
        {'label': 'Store', 'value': m['name']!},
        {'label': 'Phone', 'value': m['phone']!},
      ],
    );
  }

  Widget _buildAgentCard(BuildContext context) {
    final a = _order['agent'] as Map<String, String>;
    return _buildInfoCard(
      title: 'Delivery Agent',
      icon: Icons.delivery_dining,
      iconColor: AppColors.secondary,
      rows: [
        {'label': 'Name', 'value': a['name']!},
        {'label': 'Phone', 'value': a['phone']!},
        {'label': 'Vehicle', 'value': a['vehicle']!},
      ],
      trailing: OutlinedButton(
        onPressed: () {
          // TODO: Navigate to assign order screen
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Reassign', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: AppTextStyles.titleLarge),
            const Divider(),
            ..._items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.eco_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'] as String, style: AppTextStyles.bodyMedium),
                            Text('Qty: ${item['qty']}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      Text(item['price'] as String, style: AppTextStyles.labelLarge),
                    ],
                  ),
                )),
            const Divider(),
            _totalRow('Subtotal', '₹375'),
            _totalRow('Delivery Fee', '₹30'),
            _totalRow('Discount', '-₹0'),
            const Divider(),
            _totalRow('Total', '₹405', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium),
          Text(value, style: isBold ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary) : AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Actions', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showActionDialog(context, 'Cancel Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showActionDialog(context, 'Force Complete'),
                    child: const Text('Force Complete'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showActionDialog(context, 'Refund'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    child: const Text('Refund'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLog() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity Log', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._activityLog.asMap().entries.map((e) {
              final i = e.key;
              final log = e.value;
              final isLast = i == _activityLog.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log['event']!, style: AppTextStyles.bodyMedium),
                          Text('${log['date']} at ${log['time']}', style: AppTextStyles.bodySmall),
                        ],
                      ),
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
