import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/data/models/order_model.dart';
import 'package:greenbasket_app/utils/helpers.dart';
import '../../../data/repositories/merchant_repository.dart';

class MerchantOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const MerchantOrderDetailScreen({super.key, required this.order});

  @override
  State<MerchantOrderDetailScreen> createState() =>
      _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState
    extends State<MerchantOrderDetailScreen> {
  final _repo = MerchantRepository();
  late String _currentStatus;
  bool _isUpdating = false;
  bool _isLoadingAgents = false;
  List<Map<String, dynamic>> _availableAgents = [];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  String get _nextStatus {
    switch (_currentStatus.toLowerCase()) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'preparing';
      case 'preparing':
        return 'ready';
      default:
        return '';
    }
  }

  String? get _primaryActionLabel {
    switch (_currentStatus.toLowerCase()) {
      case 'pending':
        return 'Confirm Order';
      case 'confirmed':
        return 'Start Preparing';
      case 'preparing':
        return 'Mark Ready';
      default:
        return null;
    }
  }

  Color get _statusColor {
    switch (_currentStatus.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'preparing':
        return AppColors.secondary;
      case 'ready':
        return AppColors.success;
      case 'dispatched':
      case 'out_for_delivery':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  Color get _statusBgColor => _statusColor.withOpacity(0.1);

  Future<void> _advanceStatus() async {
    final next = _nextStatus;
    if (next.isEmpty) return;
    setState(() => _isUpdating = true);
    try {
      await _repo.updateOrderStatus(widget.order.id, next);
      setState(() => _currentStatus = next);
      Get.snackbar(
        'Status Updated',
        'Order is now ${next.capitalizeFirst}',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar('Error', 'Could not update order status',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _loadAgentsAndShow() async {
    setState(() => _isLoadingAgents = true);
    try {
      final agents = await _repo.getAvailableAgents();
      _availableAgents = agents;
    } catch (_) {
      _availableAgents = [];
    } finally {
      setState(() => _isLoadingAgents = false);
      if (mounted) _showAssignAgentSheet();
    }
  }

  void _showAssignAgentSheet() {
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
            if (_availableAgents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text('No agents available right now.',
                      style: AppTextStyles.bodyMedium),
                ),
              )
            else
              ..._availableAgents.map((agent) {
                final id = agent['_id'] ?? agent['id'] ?? '';
                final name = agent['name'] ?? agent['agentName'] ?? 'Agent';
                final status = agent['status'] ?? 'Available';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  title: Text(name, style: AppTextStyles.bodyMedium),
                  subtitle: Text(status,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.success)),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await _repo.assignAgentToOrder(
                            widget.order.id, id);
                        Get.snackbar(
                          'Agent Assigned',
                          '$name assigned to order #${widget.order.orderNumber}',
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } catch (_) {
                        Get.snackbar('Error', 'Could not assign agent',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs)),
                    child: const Text('Assign'),
                  ),
                );
              }),
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
        title: Text('Order #${widget.order.orderNumber}'),
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
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border:
                        Border.all(color: _statusColor.withOpacity(0.3)),
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
                        _currentStatus.capitalizeFirst ?? _currentStatus,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: _statusColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  AppHelpers.formatDateTime(widget.order.createdAt),
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
                          'C',
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Order #${widget.order.orderNumber}',
                                style: AppTextStyles.titleMedium),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_outlined,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Contact Customer',
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
                        child: Text(
                            widget.order.deliveryAddress.fullAddress,
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
                  Text('Order Items', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ...widget.order.items.map((item) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
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
                              child: item.productImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.sm),
                                      child: Image.network(
                                          item.productImage!,
                                          fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.eco_outlined,
                                      color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: AppTextStyles.bodyMedium),
                                  Text('Qty: ${item.quantity}',
                                      style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            Text(
                              AppHelpers.formatCurrency(item.itemTotal),
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _totalRow('Subtotal',
                      AppHelpers.formatCurrency(widget.order.subtotal)),
                  const SizedBox(height: AppSpacing.xs),
                  _totalRow('Delivery',
                      AppHelpers.formatCurrency(widget.order.deliveryFee)),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _totalRow('Total',
                      AppHelpers.formatCurrency(widget.order.total),
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Special instructions
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
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                          color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.order.notes?.isNotEmpty == true
                          ? widget.order.notes!
                          : 'No special instructions provided',
                      style: AppTextStyles.bodyMedium,
                    ),
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
                    onPressed: _isUpdating ? null : _advanceStatus,
                    child: _isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : Text(_primaryActionLabel!),
                  ),
                ),
              if (_primaryActionLabel != null)
                const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingAgents
                      ? null
                      : _loadAgentsAndShow,
                  icon: _isLoadingAgents
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.delivery_dining_outlined,
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
              ? AppTextStyles.titleLarge.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
