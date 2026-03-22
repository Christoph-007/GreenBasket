import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Pre-filled mock data — TODO: replace with product from API/args
  final _nameController = TextEditingController(text: 'Fresh Tomatoes');
  final _descController = TextEditingController(
      text: 'Farm-fresh tomatoes harvested daily. Rich in vitamins and antioxidants.');
  String? _selectedCategory = 'Vegetables';
  String? _selectedSubcategory = 'Seasonal';

  final _priceController = TextEditingController(text: '45');
  final _mrpController = TextEditingController(text: '60');
  final _stockController = TextEditingController(text: '120');
  String _selectedUnit = 'kg';
  final _minOrderController = TextEditingController(text: '1');
  final _prepTimeController = TextEditingController(text: '15');

  bool _isOrganic = true;
  final _tagsController = TextEditingController();
  List<String> _tags = ['fresh', 'seasonal', 'local'];
  final _keywordsController =
      TextEditingController(text: 'tomato, fresh tomato, red tomato');

  // Mock existing images
  final List<bool> _existingImages = [true, true, false];

  final List<String> _categories = ['Vegetables', 'Fruits', 'Dairy', 'Grains'];
  final Map<String, List<String>> _subcategories = {
    'Vegetables': ['Leafy Greens', 'Root Vegetables', 'Gourds', 'Seasonal'],
    'Fruits': ['Citrus', 'Tropical', 'Berries', 'Seasonal'],
    'Dairy': ['Milk', 'Cheese', 'Curd', 'Paneer'],
    'Grains': ['Rice', 'Wheat', 'Pulses', 'Millets'],
  };
  final List<String> _units = ['kg', 'piece', 'bunch', 'litre', 'gram'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _stockController.dispose();
    _minOrderController.dispose();
    _prepTimeController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() => _tags.add(tag.trim()));
      _tagsController.clear();
    }
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  void _saveChanges() {
    // TODO: call API to update product
    Get.back();
    Get.snackbar(
      'Updated',
      'Product updated successfully!',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Product', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to delete "Fresh Tomatoes"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: call API to delete product
              Get.back();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
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
        title: const Text('Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text('Save',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.primary)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildTabBar(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _currentStep == 0
            ? _buildStep1()
            : _currentStep == 1
                ? _buildStep2()
                : _buildStep3(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Basic Info', 'Pricing', 'Images'];
    return Container(
      color: AppColors.surface,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentStep = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g. Fresh Tomatoes',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Describe your product...',
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (v) => setState(() {
                _selectedCategory = v;
                _selectedSubcategory = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDropdown(
              label: 'Subcategory',
              value: _selectedSubcategory,
              items: _selectedCategory != null
                  ? _subcategories[_selectedCategory!]!
                  : [],
              onChanged: (v) =>
                  setState(() => _selectedSubcategory = v),
              enabled: _selectedCategory != null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Selling Price (₹)',
                  keyboardType: TextInputType.number,
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildTextField(
                  controller: _mrpController,
                  label: 'MRP (₹)',
                  keyboardType: TextInputType.number,
                  prefixText: '₹ ',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stockController,
                  label: 'Stock Quantity',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  onChanged: (v) => setState(() => _selectedUnit = v!),
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: _units
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minOrderController,
                  label: 'Min Order Qty',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildTextField(
                  controller: _prepTimeController,
                  label: 'Prep Time (min)',
                  keyboardType: TextInputType.number,
                  suffixText: 'min',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Images', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(3, (i) => _buildImageSlot(i)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Additional Details', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_outlined,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Organic Product', style: AppTextStyles.bodyMedium),
                  ],
                ),
                Switch(
                  value: _isOrganic,
                  onChanged: (v) => setState(() => _isOrganic = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Tags', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              ..._tags.map((tag) => Chip(
                    label: Text(tag,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: AppColors.primaryContainer,
                    side: const BorderSide(color: AppColors.primaryLight),
                  )),
              SizedBox(
                width: 140,
                height: 36,
                child: TextField(
                  controller: _tagsController,
                  style: AppTextStyles.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Add tag...',
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textHint),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: _addTag,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _keywordsController,
            label: 'Search Keywords',
            hint: 'comma separated keywords',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    final hasImage = _existingImages[index];
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: index < 2 ? AppSpacing.sm : 0),
        child: GestureDetector(
          onTap: () {
            // TODO: open image picker
            setState(() => _existingImages[index] = true);
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color:
                  hasImage ? AppColors.primaryContainer : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasImage ? AppColors.primary : AppColors.border,
                width: hasImage ? 1.5 : 1,
              ),
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      const Center(
                        child: Icon(Icons.image,
                            color: AppColors.primary, size: 36),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _existingImages[index] = false),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.textHint, size: 28),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Add Photo',
                          style: AppTextStyles.labelSmall),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Update Product'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _deleteProduct,
                child: Text(
                  'Delete Product',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: enabled ? onChanged : null,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
