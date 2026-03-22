import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

enum OrderStatus { pending, confirmed, preparing, ready, dispatched }

class MerchantOrderDetailScreen extends StatefulWidget {
  const MerchantOrderDetailScreen({super.key});

  @override
  State<MerchantOrderDetailScreen> createState() =>
      _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState
    extends State<MerchantOrderDetailScreen> {
  // TODO: replace with real order data passed via Get.arguments
  OrderStatus _status = OrderStatus.pending;

  final _orderNumber = 'GB2024001';
  final _customerName = 'Priya Sharma';
  final _customerPhone = '+91 98765 43210';
  final _customerAddress =
      '204, Green Residency, MG Road, Bengaluru - 560001';
  final _specialInstructions =
      'Please pack items carefully. Ring bell twice on arrival.';

  final List<Map<String, dynamic>> _items = [
    {'name': 'Fresh Tomatoes', 'qty': 2, 'unit': 'kg', 'price': 90.0},
    {'name': 'Baby Spinach', 'qty': 1, 'unit': 'bunch', 'price': 35.0},
    {'name': 'Organic Carrots', 'qty': 0.5, 'unit': 'kg', 'price': 30.0},
    {'name': 'Coriander Leaves', 'qty': 1, 'unit': 'bunch', 'price': 15.0},
  ];

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + (item['price'] as double));
  double get _delivery => 40.0;
  double get _total => _subtotal + _delivery;

  String get _statusLabel {
    switch (_status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.dispatched:
        return 'Dispatched';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.secondary;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.dispatched:
        return AppColors.primary;
    }
  }

  Color get _statusBgColor {
    switch (_status) {
      case OrderStatus.pending:
        return AppColors.warning.withOpacity(0.1);
      case OrderStatus.confirmed:
        return AppColors.info.withOpacity(0.1);
      case OrderStatus.preparing:
        return AppColors.secondary.withOpacity(0.1);
      case OrderStatus.ready:
        return AppColors.success.withOpacity(0.1);
      case OrderStatus.dispatched:
        return AppColors.primary.withOpacity(0.1);
    }
  }

  String? get _primaryActionLabel {
    switch (_status) {
      case OrderStatus.pending:
        return 'Confirm Order';
      case OrderStatus.confirmed:
        return 'Start Preparing';
      case OrderStatus.preparing:
        return 'Mark Ready';
      case OrderStatus.ready:
      case OrderStatus.dispatched:
        return null;
    }
  }

  void _advanceStatus() {
    setState(() {
      switch (_status) {
        case OrderStatus.pending:
          _status = OrderStatus.confirmed;
          break;
        case OrderStatus.confirmed:
          _status = OrderStatus.preparing;
          break;
        case OrderStatus.preparing:
          _status = OrderStatus.ready;
          break;
        default:
          break;
      }
    });
  }

  void _assignDeliveryAgent() {
    // TODO: navigate to assign delivery agent screen or show bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Delivery Agent',
                style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ...['Rajan Kumar', 'Suresh M.', 'Deepak R.'].map((name) =>
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(name[0],
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary)),
                  ),
                  title: Text(name, style: AppTextStyles.bodyMedium),
                  subtitle: Text('Available',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.success)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.snackbar('Agent Assigned',
                          '$name assigned to order #$_orderNumber',
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs)),
                    child: const Text('Assign'),
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
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
        title: Text('Order #$_orderNumber'),
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
            // Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _statusLabel,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: _statusColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Mar 22, 2024 · 10:30 AM',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Customer info card
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Details',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          _customerName[0],
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_customerName,
                                style: AppTextStyles.titleMedium),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () {
                                // TODO: launch phone dialer
                                HapticFeedback.lightImpact();
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_outlined,
                                      size: 14,
                                      color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    _customerPhone,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                            color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(_customerAddress,
                            style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Items list
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Items',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ..._items.map((item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.eco_outlined,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] as String,
                                      style:
                                          AppTextStyles.bodyMedium),
                                  Text(
                                    '${item['qty']} ${item['unit']}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(item['price'] as double).toStringAsFixed(0)}',
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _totalRow('Subtotal',
                      '₹${_subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: AppSpacing.xs),
                  _totalRow('Delivery',
                      '₹${_delivery.toStringAsFixed(0)}'),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _totalRow('Total', '₹${_total.toStringAsFixed(0)}',
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Special instructions
            if (_specialInstructions.isNotEmpty)
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes_outlined,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Special Instructions',
                            style: AppTextStyles.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color:
                                AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Text(_specialInstructions,
                          style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_primaryActionLabel != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _advanceStatus,
                    child: Text(_primaryActionLabel!),
                  ),
                ),
              if (_primaryActionLabel != null)
                const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _assignDeliveryAgent,
                  icon: const Icon(Icons.delivery_dining_outlined,
                      size: 18),
                  label: const Text('Assign Delivery Agent'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _totalRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          amount,
          style: isTotal
              ? AppTextStyles.titleLarge
                  .copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
