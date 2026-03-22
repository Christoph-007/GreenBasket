import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  // Store info — TODO: load from API
  final _storeNameController =
      TextEditingController(text: 'Green Harvest Store');
  final _storeDescController = TextEditingController(
      text: 'Fresh organic vegetables and fruits delivered to your doorstep.');
  final _storePhoneController =
      TextEditingController(text: '+91 98765 43210');

  // Notifications
  bool _newOrdersNotif = true;
  bool _lowStockNotif = true;
  bool _reviewNotif = false;

  // Auto-accept & prep time
  bool _autoAccept = false;
  int _defaultPrepTime = 30;

  // Store hours: Mon=0 ... Sun=6
  final List<Map<String, dynamic>> _storeHours = [
    {
      'day': 'Monday',
      'open': true,
      'openTime': const TimeOfDay(hour: 8, minute: 0),
      'closeTime': const TimeOfDay(hour: 21, minute: 0),
    },
    {
      'day': 'Tuesday',
      'open': true,
      'openTime': const TimeOfDay(hour: 8, minute: 0),
      'closeTime': const TimeOfDay(hour: 21, minute: 0),
    },
    {
      'day': 'Wednesday',
      'open': true,
      'openTime': const TimeOfDay(hour: 8, minute: 0),
      'closeTime': const TimeOfDay(hour: 21, minute: 0),
    },
    {
      'day': 'Thursday',
      'open': true,
      'openTime': const TimeOfDay(hour: 8, minute: 0),
      'closeTime': const TimeOfDay(hour: 21, minute: 0),
    },
    {
      'day': 'Friday',
      'open': true,
      'openTime': const TimeOfDay(hour: 8, minute: 0),
      'closeTime': const TimeOfDay(hour: 22, minute: 0),
    },
    {
      'day': 'Saturday',
      'open': true,
      'openTime': const TimeOfDay(hour: 7, minute: 0),
      'closeTime': const TimeOfDay(hour: 22, minute: 0),
    },
    {
      'day': 'Sunday',
      'open': false,
      'openTime': const TimeOfDay(hour: 9, minute: 0),
      'closeTime': const TimeOfDay(hour: 18, minute: 0),
    },
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index, bool isOpen) async {
    final current = isOpen
        ? _storeHours[index]['openTime'] as TimeOfDay
        : _storeHours[index]['closeTime'] as TimeOfDay;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _storeHours[index]['openTime'] = picked;
        } else {
          _storeHours[index]['closeTime'] = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _saveSettings() {
    // TODO: call API to save all settings
    Get.back();
    Get.snackbar(
      'Settings Saved',
      'Store settings updated successfully',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Store Settings'),
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
            // Store Info Section
            _sectionHeader('Store Information'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _storeNameController,
              label: 'Store Name',
              hint: 'Your store name',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _storeDescController,
              label: 'Store Description',
              hint: 'Brief description of your store...',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _storePhoneController,
              label: 'Store Phone',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Store Hours
            _sectionHeader('Store Hours'),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _storeHours.asMap().entries.map((e) {
                  final i = e.key;
                  final day = e.value;
                  final isOpen = day['open'] as bool;
                  return Column(
                    children: [
                      if (i > 0) const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    day['day'] as String,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                            fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  isOpen ? 'Open' : 'Closed',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isOpen
                                        ? AppColors.success
                                        : AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Switch(
                                  value: isOpen,
                                  onChanged: (v) => setState(
                                      () => _storeHours[i]['open'] = v),
                                  activeColor: AppColors.primary,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            if (isOpen) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Expanded(
                                    child: _timePickerButton(
                                      'Opens',
                                      _formatTime(
                                          day['openTime'] as TimeOfDay),
                                      () => _pickTime(i, true),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm),
                                    child: Icon(Icons.arrow_forward,
                                        size: 16,
                                        color: AppColors.textHint),
                                  ),
                                  Expanded(
                                    child: _timePickerButton(
                                      'Closes',
                                      _formatTime(
                                          day['closeTime'] as TimeOfDay),
                                      () => _pickTime(i, false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notifications
            _sectionHeader('Notifications'),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _notifToggle(
                    'New Order Alerts',
                    'Get notified for every new order',
                    Icons.shopping_bag_outlined,
                    _newOrdersNotif,
                    (v) => setState(() => _newOrdersNotif = v),
                  ),
                  const Divider(height: 1),
                  _notifToggle(
                    'Low Stock Alerts',
                    'Alert when products run low',
                    Icons.inventory_2_outlined,
                    _lowStockNotif,
                    (v) => setState(() => _lowStockNotif = v),
                  ),
                  const Divider(height: 1),
                  _notifToggle(
                    'Review Notifications',
                    'Notify when customers leave reviews',
                    Icons.star_outline_rounded,
                    _reviewNotif,
                    (v) => setState(() => _reviewNotif = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Order Management
            _sectionHeader('Order Management'),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Auto-accept Orders',
                        style: AppTextStyles.bodyMedium),
                    subtitle: Text(
                      'Automatically confirm incoming orders',
                      style: AppTextStyles.bodySmall,
                    ),
                    secondary: const Icon(Icons.auto_awesome_outlined,
                        color: AppColors.primary),
                    value: _autoAccept,
                    onChanged: (v) => setState(() => _autoAccept = v),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Default Prep Time',
                                  style: AppTextStyles.bodyMedium),
                              Text('$_defaultPrepTime minutes',
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _stepperButton(
                              Icons.remove,
                              () {
                                if (_defaultPrepTime > 5) {
                                  setState(() => _defaultPrepTime -= 5);
                                }
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 44,
                              height: 36,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Center(
                                child: Text(
                                  '$_defaultPrepTime',
                                  style: AppTextStyles.titleMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _stepperButton(
                              Icons.add,
                              () => setState(() => _defaultPrepTime += 5),
                            ),
                          ],
                        ),
                      ],
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) =>
      Text(title, style: AppTextStyles.titleLarge);

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _timePickerButton(
      String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_outlined,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
                  Text(time,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    void Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      secondary: Icon(icon, color: AppColors.primary, size: 22),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
