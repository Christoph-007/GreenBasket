import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class ProductStockScreen extends StatefulWidget {
  const ProductStockScreen({super.key});

  @override
  State<ProductStockScreen> createState() => _ProductStockScreenState();
}

class _ProductStockScreenState extends State<ProductStockScreen> {
  // TODO: replace with actual product data from args / API
  final String _productName = 'Fresh Tomatoes';
  final String _unit = 'kg';
  int _currentStock = 120;
  int _adjustAmount = 1;
  bool _lowStockAlertEnabled = true;
  final _thresholdController = TextEditingController(text: '20');
  final _adjustController = TextEditingController(text: '1');

  // Mock stock history — TODO: fetch from API
  final List<Map<String, dynamic>> _history = [
    {
      'date': 'Today, 09:15 AM',
      'change': 50,
      'reason': 'Restock',
      'resulting': 120,
    },
    {
      'date': 'Yesterday, 02:30 PM',
      'change': -18,
      'reason': 'Orders fulfilled',
      'resulting': 70,
    },
    {
      'date': 'Mar 20, 11:00 AM',
      'change': 80,
      'reason': 'Restock',
      'resulting': 88,
    },
    {
      'date': 'Mar 19, 05:00 PM',
      'change': -22,
      'reason': 'Orders fulfilled',
      'resulting': 8,
    },
    {
      'date': 'Mar 18, 10:00 AM',
      'change': 100,
      'reason': 'Initial stock',
      'resulting': 30,
    },
  ];

  @override
  void dispose() {
    _thresholdController.dispose();
    _adjustController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _adjustAmount++;
      _adjustController.text = _adjustAmount.toString();
    });
  }

  void _decrement() {
    if (_adjustAmount > 1) {
      setState(() {
        _adjustAmount--;
        _adjustController.text = _adjustAmount.toString();
      });
    }
  }

  void _updateStock(bool add) {
    setState(() {
      if (add) {
        _currentStock += _adjustAmount;
      } else {
        _currentStock =
            (_currentStock - _adjustAmount).clamp(0, 99999);
      }
    });
    Get.snackbar(
      'Stock Updated',
      '${add ? '+' : '-'}$_adjustAmount $_unit recorded',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLow = _currentStock <=
        (int.tryParse(_thresholdController.text) ?? 20);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Stock'),
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
            // Product name
            Text(_productName,
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.md),

            // Current stock card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Stock',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_currentStock',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          _unit,
                          style: AppTextStyles.titleLarge
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  if (isLow && _lowStockAlertEnabled) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text('Low Stock',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Adjust stock section
            Text('Adjust Stock', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleButton(
                        Icons.remove,
                        _decrement,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _adjustController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.headlineLarge,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (v) {
                            _adjustAmount = int.tryParse(v) ?? 1;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _circleButton(
                        Icons.add,
                        _increment,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  Text(_unit,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateStock(false),
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 18),
                          label: const Text('Remove Stock'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                                color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStock(true),
                          icon: const Icon(Icons.add_circle_outline,
                              size: 18),
                          label: const Text('Add Stock'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Low stock alert
            Text('Low Stock Alert', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable low stock alert',
                          style: AppTextStyles.bodyMedium),
                      Switch(
                        value: _lowStockAlertEnabled,
                        onChanged: (v) =>
                            setState(() => _lowStockAlertEnabled = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_lowStockAlertEnabled) ...[
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Alert threshold ($_unit)',
                        hintText: '20',
                        suffixText: _unit,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stock history
            Text('Stock History', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(_history.length, (i) {
              final item = _history[i];
              final isAdd = (item['change'] as int) > 0;
              return Container(
                margin:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isAdd
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAdd
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isAdd
                            ? AppColors.success
                            : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(item['reason'] as String,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(
                                      fontWeight:
                                          FontWeight.w500)),
                          Text(item['date'] as String,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isAdd ? '+' : ''}${item['change']} $_unit',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isAdd
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        Text(
                          '→ ${item['resulting']} $_unit',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: save all stock settings via API
                Get.back();
              },
              child: const Text('Save Stock Settings'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
