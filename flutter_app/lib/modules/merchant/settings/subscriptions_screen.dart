import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _filterStatus = 'All';

  // Mock subscriber data — TODO: fetch from API
  final List<Map<String, dynamic>> _subscriptions = [
    {
      'customer': 'Priya Sharma',
      'plan': 'Vegetable Box',
      'frequency': 'Weekly',
      'items': ['Tomatoes 2kg', 'Spinach 1 bunch', 'Carrots 500g'],
      'nextDelivery': 'Mar 25',
      'status': 'Active',
      'amount': 450.0,
    },
    {
      'customer': 'Rahul Gupta',
      'plan': 'Dairy Pack',
      'frequency': 'Daily',
      'items': ['Full Cream Milk 1L', 'Curd 500g'],
      'nextDelivery': 'Mar 23',
      'status': 'Active',
      'amount': 120.0,
    },
    {
      'customer': 'Anjali Mehta',
      'plan': 'Fruit Basket',
      'frequency': 'Monthly',
      'items': ['Mangoes 2kg', 'Bananas 1 dozen', 'Papaya 1 piece'],
      'nextDelivery': 'Apr 1',
      'status': 'Active',
      'amount': 680.0,
    },
    {
      'customer': 'Vikram Singh',
      'plan': 'Organic Mix',
      'frequency': 'Weekly',
      'items': ['Mixed Greens 500g', 'Tomatoes 1kg'],
      'nextDelivery': 'Mar 25',
      'status': 'Paused',
      'amount': 380.0,
    },
    {
      'customer': 'Sunita Patel',
      'plan': 'Vegetable Box',
      'frequency': 'Weekly',
      'items': ['Brinjal 500g', 'Bitter Gourd 500g', 'Ladies Finger 500g'],
      'nextDelivery': '-',
      'status': 'Cancelled',
      'amount': 350.0,
    },
    {
      'customer': 'Mohan Rao',
      'plan': 'Dairy Pack',
      'frequency': 'Daily',
      'items': ['Toned Milk 500ml', 'Paneer 200g'],
      'nextDelivery': 'Mar 23',
      'status': 'Active',
      'amount': 95.0,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == 'All') return _subscriptions;
    return _subscriptions
        .where((s) => s['status'] == _filterStatus)
        .toList();
  }

  int get _activeCount =>
      _subscriptions.where((s) => s['status'] == 'Active').length;

  double get _monthlyRevenue {
    return _subscriptions
        .where((s) => s['status'] == 'Active')
        .fold(0.0, (sum, s) {
      final freq = s['frequency'] as String;
      final amount = s['amount'] as double;
      if (freq == 'Daily') return sum + amount * 30;
      if (freq == 'Weekly') return sum + amount * 4;
      return sum + amount;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Paused':
        return AppColors.warning;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  void _showSubscriptionDetail(Map<String, dynamic> sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      (sub['customer'] as String)[0],
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub['customer'] as String,
                            style: AppTextStyles.titleLarge),
                        Text(
                          '${sub['plan']} · ${sub['frequency']}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: _statusColor(sub['status'] as String)
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      sub['status'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: _statusColor(sub['status'] as String)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text('Subscription Items',
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ...(sub['items'] as List<String>).map((item) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(item, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              _detailRow('Frequency', sub['frequency'] as String),
              _detailRow('Next Delivery', sub['nextDelivery'] as String),
              _detailRow(
                  'Amount',
                  '₹${(sub['amount'] as double).toStringAsFixed(0)} per delivery'),
              const SizedBox(height: AppSpacing.lg),
              if (sub['status'] == 'Active')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: pause subscription
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(
                              color: AppColors.warning),
                        ),
                        child: const Text('Pause'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Subscriptions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Stats header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: _statItem(
                    'Active Subscribers',
                    '$_activeCount',
                    AppColors.success,
                    Icons.people_outline,
                  ),
                ),
                Container(
                    width: 1, height: 48, color: AppColors.border),
                Expanded(
                  child: _statItem(
                    'Monthly Revenue',
                    '₹${_monthlyRevenue.toStringAsFixed(0)}',
                    AppColors.primary,
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: ['All', 'Active', 'Paused', 'Cancelled']
                  .map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _filterStatus = status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.subscriptions_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No $_filterStatus subscriptions',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final sub = _filtered[i];
                      return _buildSubscriptionCard(sub);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
      String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.textPrimary)),
                Text(label,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> sub) {
    final status = sub['status'] as String;
    final statusColor = _statusColor(status);
    final items = sub['items'] as List<String>;

    return GestureDetector(
      onTap: () => _showSubscriptionDetail(sub),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      (sub['customer'] as String)[0],
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub['customer'] as String,
                            style: AppTextStyles.titleMedium),
                        Text(
                          '${sub['plan']} · ${sub['frequency']}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: statusColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${(sub['amount'] as double).toStringAsFixed(0)}',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items.take(2).join(', ') +
                          (items.length > 2
                              ? ' +${items.length - 2} more'
                              : ''),
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status == 'Active') ...[
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Next: ${sub['nextDelivery']}',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
