import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../../../data/repositories/merchant_repository.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _repo = MerchantRepository();
  bool _isLoading = true;
  bool _isSaving = false;

  final _storeNameController = TextEditingController();
  final _storeDescController = TextEditingController();
  final _storePhoneController = TextEditingController();

  bool _newOrdersNotif = true;
  bool _lowStockNotif = true;
  bool _reviewNotif = false;
  bool _autoAccept = false;
  int _defaultPrepTime = 30;

  final List<Map<String, dynamic>> _storeHours = [
    {'day': 'Monday', 'open': true, 'openTime': const TimeOfDay(hour: 8, minute: 0), 'closeTime': const TimeOfDay(hour: 21, minute: 0)},
    {'day': 'Tuesday', 'open': true, 'openTime': const TimeOfDay(hour: 8, minute: 0), 'closeTime': const TimeOfDay(hour: 21, minute: 0)},
    {'day': 'Wednesday', 'open': true, 'openTime': const TimeOfDay(hour: 8, minute: 0), 'closeTime': const TimeOfDay(hour: 21, minute: 0)},
    {'day': 'Thursday', 'open': true, 'openTime': const TimeOfDay(hour: 8, minute: 0), 'closeTime': const TimeOfDay(hour: 21, minute: 0)},
    {'day': 'Friday', 'open': true, 'openTime': const TimeOfDay(hour: 8, minute: 0), 'closeTime': const TimeOfDay(hour: 22, minute: 0)},
    {'day': 'Saturday', 'open': true, 'openTime': const TimeOfDay(hour: 7, minute: 0), 'closeTime': const TimeOfDay(hour: 22, minute: 0)},
    {'day': 'Sunday', 'open': false, 'openTime': const TimeOfDay(hour: 9, minute: 0), 'closeTime': const TimeOfDay(hour: 18, minute: 0)},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final result = await _repo.getStoreSettings();
      final data = result['data'] ?? result;
      setState(() {
        _storeNameController.text =
            data['storeName'] ?? data['businessName'] ?? '';
        _storeDescController.text = data['description'] ?? data['storeDescription'] ?? '';
        _storePhoneController.text = data['phone'] ?? data['storePhone'] ?? '';
        _newOrdersNotif = data['notifications']?['newOrders'] ?? data['newOrdersNotif'] ?? true;
        _lowStockNotif = data['notifications']?['lowStock'] ?? data['lowStockNotif'] ?? true;
        _reviewNotif = data['notifications']?['reviews'] ?? data['reviewNotif'] ?? false;
        _autoAccept = data['autoAccept'] ?? false;
        _defaultPrepTime = data['defaultPrepTime'] ?? 30;

        // Parse store hours if available
        final hoursRaw = data['storeHours'] ?? data['hours'];
        if (hoursRaw is List) {
          for (int i = 0; i < _storeHours.length && i < hoursRaw.length; i++) {
            final h = hoursRaw[i] as Map<String, dynamic>;
            _storeHours[i]['open'] = h['open'] ?? _storeHours[i]['open'];
            if (h['openTime'] != null) {
              final parts = (h['openTime'] as String).split(':');
              _storeHours[i]['openTime'] = TimeOfDay(
                  hour: int.tryParse(parts[0]) ?? 8,
                  minute: int.tryParse(parts[1]) ?? 0);
            }
            if (h['closeTime'] != null) {
              final parts = (h['closeTime'] as String).split(':');
              _storeHours[i]['closeTime'] = TimeOfDay(
                  hour: int.tryParse(parts[0]) ?? 21,
                  minute: int.tryParse(parts[1]) ?? 0);
            }
          }
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
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
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
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

  String _timeOfDayToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _repo.saveStoreSettings({
        'storeName': _storeNameController.text.trim(),
        'description': _storeDescController.text.trim(),
        'phone': _storePhoneController.text.trim(),
        'notifications': {
          'newOrders': _newOrdersNotif,
          'lowStock': _lowStockNotif,
          'reviews': _reviewNotif,
        },
        'autoAccept': _autoAccept,
        'defaultPrepTime': _defaultPrepTime,
        'storeHours': _storeHours.map((h) => {
              'day': h['day'],
              'open': h['open'],
              'openTime': _timeOfDayToString(h['openTime'] as TimeOfDay),
              'closeTime': _timeOfDayToString(h['closeTime'] as TimeOfDay),
            }).toList(),
      });
      Get.back();
      Get.snackbar(
        'Settings Saved',
        'Store settings updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to save settings. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isSaving = false);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    hint: '+91 XXXXX XXXXX',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.lg),

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
                                        child: Text(day['day'] as String,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500)),
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
                                  _stepperButton(Icons.remove, () {
                                    if (_defaultPrepTime > 5) {
                                      setState(() => _defaultPrepTime -= 5);
                                    }
                                  }),
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    width: 44,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.border),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Center(
                                      child: Text('$_defaultPrepTime',
                                          style: AppTextStyles.titleMedium),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _stepperButton(Icons.add,
                                      () => setState(() => _defaultPrepTime += 5)),
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
                color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Settings'),
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

  Widget _timePickerButton(String label, String time, VoidCallback onTap) {
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
            const Icon(Icons.access_time_outlined,
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

  Widget _notifToggle(String title, String subtitle, IconData icon, bool value,
      void Function(bool) onChanged) {
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
