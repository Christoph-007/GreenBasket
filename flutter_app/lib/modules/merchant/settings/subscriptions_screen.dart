import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../../../data/repositories/merchant_repository.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _repo = MerchantRepository();
  bool _isLoading = true;
  String _filterStatus = 'All';
  List<Map<String, dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    try {
      final subs = await _repo.getSubscriptions();
      setState(() {
        _subscriptions = subs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == 'All') return _subscriptions;
    return _subscriptions.where((s) {
      final status = (s['status'] ?? '').toString();
      return status.toLowerCase() == _filterStatus.toLowerCase();
    }).toList();
  }

  int get _activeCount => _subscriptions
      .where((s) => (s['status'] ?? '').toString().toLowerCase() == 'active')
      .length;

  double get _monthlyRevenue {
    return _subscriptions
        .where(
            (s) => (s['status'] ?? '').toString().toLowerCase() == 'active')
        .fold(0.0, (sum, s) {
      final freq = (s['frequency'] ?? s['deliveryFrequency'] ?? '').toString();
      final amount = (s['amount'] ?? s['price'] ?? 0).toDouble();
      if (freq.toLowerCase() == 'daily') return sum + amount * 30;
      if (freq.toLowerCase() == 'weekly') return sum + amount * 4;
      return sum + amount;
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'paused':
        return AppColors.warning;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  Future<void> _pauseSubscription(String id) async {
    try {
      await _repo.pauseSubscription(id);
      await _fetchSubscriptions();
      Get.snackbar('Paused', 'Subscription has been paused',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Could not pause subscription');
    }
  }

  void _showSubscriptionDetail(Map<String, dynamic> sub) {
    final id = sub['_id'] ?? sub['id'] ?? '';
    final customer =
        sub['customer'] ?? sub['customerName'] ?? 'Customer';
    final plan = sub['plan'] ?? sub['planName'] ?? 'Plan';
    final freq =
        sub['frequency'] ?? sub['deliveryFrequency'] ?? '';
    final status = (sub['status'] ?? '').toString();
    final items = (sub['items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final nextDelivery =
        sub['nextDelivery'] ?? sub['nextDeliveryDate'] ?? '-';
    final amount =
        (sub['amount'] ?? sub['price'] ?? 0).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                      customer.isNotEmpty
                          ? customer[0].toUpperCase()
                          : 'C',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer, style: AppTextStyles.titleLarge),
                        Text('$plan · $freq',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(status).withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: _statusColor(status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              if (items.isNotEmpty) ...[
                Text('Subscription Items',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                ...items.map((item) => Padding(
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
              ],
              _detailRow('Frequency', freq),
              _detailRow('Next Delivery', nextDelivery),
              _detailRow(
                  'Amount',
                  '₹${amount.toStringAsFixed(0)} per delivery'),
              const SizedBox(height: AppSpacing.lg),
              if (status.toLowerCase() == 'active')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: id.isNotEmpty
                            ? () {
                                Navigator.pop(ctx);
                                _pauseSubscription(id);
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side:
                              const BorderSide(color: AppColors.warning),
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
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Subscriptions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchSubscriptions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubscriptions,
        child: Column(
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) =>
                          _buildSubscriptionCard(_filtered[i]),
                    ),
            ),
          ],
        ),
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
    final customer =
        sub['customer'] ?? sub['customerName'] ?? 'Customer';
    final plan = sub['plan'] ?? sub['planName'] ?? 'Plan';
    final freq =
        sub['frequency'] ?? sub['deliveryFrequency'] ?? '';
    final status = (sub['status'] ?? '').toString();
    final statusColor = _statusColor(status);
    final items = (sub['items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final amount =
        (sub['amount'] ?? sub['price'] ?? 0).toDouble();
    final nextDelivery =
        sub['nextDelivery'] ?? sub['nextDeliveryDate'] ?? '-';

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
                      customer.isNotEmpty
                          ? customer[0].toUpperCase()
                          : 'C',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer,
                            style: AppTextStyles.titleMedium),
                        Text('$plan · $freq',
                            style: AppTextStyles.bodySmall),
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
                          status.isNotEmpty ? status : 'Unknown',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: statusColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
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
                      items.isNotEmpty
                          ? items.take(2).join(', ') +
                              (items.length > 2
                                  ? ' +${items.length - 2} more'
                                  : '')
                          : 'No items specified',
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status.toLowerCase() == 'active') ...[
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Next: $nextDelivery',
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
