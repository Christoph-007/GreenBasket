import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class CommissionSettingsScreen extends StatefulWidget {
  const CommissionSettingsScreen({super.key});

  @override
  State<CommissionSettingsScreen> createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  final _defaultRateController = TextEditingController(text: '12');
  bool _editingDefault = false;

  // Mock category commission rates — replace with API call
  final List<Map<String, dynamic>> _categoryRates = [
    {'category': 'Vegetables', 'icon': '🥦', 'rate': 10.0, 'editing': false},
    {'category': 'Fruits', 'icon': '🍎', 'rate': 10.0, 'editing': false},
    {'category': 'Dairy & Eggs', 'icon': '🥛', 'rate': 8.0, 'editing': false},
    {'category': 'Pantry Staples', 'icon': '🧺', 'rate': 12.0, 'editing': false},
    {'category': 'Beverages', 'icon': '🍵', 'rate': 15.0, 'editing': false},
    {'category': 'Herbs & Spices', 'icon': '🌿', 'rate': 10.0, 'editing': false},
  ];

  // Mock special merchant rates — replace with API call
  final List<Map<String, dynamic>> _specialRates = [
    {'merchant': 'Fresh Farms Organics', 'rate': 8.0, 'editing': false},
    {'merchant': 'Nature Basket', 'rate': 7.5, 'editing': false},
  ];

  final List<TextEditingController> _categoryControllers = [];
  final List<TextEditingController> _specialControllers = [];

  @override
  void initState() {
    super.initState();
    for (final cat in _categoryRates) {
      _categoryControllers.add(TextEditingController(text: '${cat['rate']}'));
    }
    for (final spec in _specialRates) {
      _specialControllers.add(TextEditingController(text: '${spec['rate']}'));
    }
  }

  @override
  void dispose() {
    _defaultRateController.dispose();
    for (final c in _categoryControllers) c.dispose();
    for (final c in _specialControllers) c.dispose();
    super.dispose();
  }

  void _saveAll() {
    // TODO: Call API to save all commission settings
    setState(() {
      for (var i = 0; i < _categoryRates.length; i++) {
        _categoryRates[i]['rate'] = double.tryParse(_categoryControllers[i].text) ?? _categoryRates[i]['rate'];
        _categoryRates[i]['editing'] = false;
      }
      for (var i = 0; i < _specialRates.length; i++) {
        _specialRates[i]['rate'] = double.tryParse(_specialControllers[i].text) ?? _specialRates[i]['rate'];
        _specialRates[i]['editing'] = false;
      }
      _editingDefault = false;
    });
    Get.snackbar('Saved', 'Commission settings have been updated.',
        backgroundColor: AppColors.success, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commission Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDefaultRateSection(),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryRates(),
            const SizedBox(height: AppSpacing.md),
            _buildSpecialRates(),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save All Changes'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultRateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Text('Global Default Rate', style: AppTextStyles.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This rate applies to all categories unless overridden below.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _editingDefault
                      ? TextField(
                          controller: _defaultRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            suffixText: '%',
                            labelText: 'Default Rate',
                          ),
                          autofocus: true,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_defaultRateController.text}%',
                              style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                            ),
                            Text('Commission on all transactions', style: AppTextStyles.bodySmall),
                          ],
                        ),
                ),
                IconButton(
                  icon: Icon(_editingDefault ? Icons.check : Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => setState(() => _editingDefault = !_editingDefault),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category_outlined, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text('Category-wise Rates', style: AppTextStyles.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._categoryRates.asMap().entries.map((e) {
              final i = e.key;
              final cat = e.value;
              final isEditing = cat['editing'] as bool;
              return Column(
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Text(cat['icon'] as String, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(cat['category'] as String, style: AppTextStyles.bodyMedium),
                        ),
                        if (isEditing)
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _categoryControllers[i],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                suffixText: '%',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              autofocus: true,
                            ),
                          )
                        else
                          Text(
                            '${cat['rate']}%',
                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                          ),
                        IconButton(
                          icon: Icon(
                            isEditing ? Icons.check : Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isEditing) {
                                cat['rate'] = double.tryParse(_categoryControllers[i].text) ?? cat['rate'];
                              }
                              cat['editing'] = !isEditing;
                            });
                          },
                        ),
                      ],
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

  Widget _buildSpecialRates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Special Merchant Rates', style: AppTextStyles.titleLarge)),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Open dialog to add special merchant rate
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Custom rates override category and default rates for specific merchants.',
              style: AppTextStyles.bodySmall,
            ),
            ..._specialRates.asMap().entries.map((e) {
              final i = e.key;
              final spec = e.value;
              final isEditing = spec['editing'] as bool;
              return Column(
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: AppColors.primaryLight, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(spec['merchant'] as String, style: AppTextStyles.bodyMedium),
                        ),
                        if (isEditing)
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _specialControllers[i],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                suffixText: '%',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              autofocus: true,
                            ),
                          )
                        else
                          Text(
                            '${spec['rate']}%',
                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary),
                          ),
                        IconButton(
                          icon: Icon(
                            isEditing ? Icons.check : Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isEditing) {
                                spec['rate'] = double.tryParse(_specialControllers[i].text) ?? spec['rate'];
                              }
                              spec['editing'] = !isEditing;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                          onPressed: () {
                            setState(() => _specialRates.removeAt(i));
                          },
                        ),
                      ],
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
