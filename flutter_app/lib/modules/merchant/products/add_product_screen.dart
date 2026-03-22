import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;

  // Step 2
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedUnit = 'kg';
  final _minOrderController = TextEditingController(text: '1');
  final _prepTimeController = TextEditingController(text: '30');

  // Step 3
  bool _isOrganic = false;
  final _tagsController = TextEditingController();
  final _keywordsController = TextEditingController();
  final List<String> _tags = [];
  final List<bool> _imageSlots = [false, false, false];

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

  void _nextStep() {
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _submitProduct() {
    // TODO: call API to create product
    Get.back();
    Get.snackbar(
      'Success',
      'Product added successfully!',
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
        title: const Text('Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildStepIndicator(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentStep == 0
              ? _buildStep1()
              : _currentStep == 1
                  ? _buildStep2()
                  : _buildStep3(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: List.generate(3, (i) {
          final isCompleted = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppColors.primary
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text(
                            '${i + 1}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  i == 0
                      ? 'Basic Info'
                      : i == 1
                          ? 'Pricing'
                          : 'Details',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs),
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Product Information'),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _nameController,
            label: 'Product Name',
            hint: 'e.g. Fresh Tomatoes',
            validator: (v) =>
                v == null || v.isEmpty ? 'Please enter product name' : null,
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
            onChanged: (v) => setState(() => _selectedSubcategory = v),
            enabled: _selectedCategory != null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Pricing & Stock'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Selling Price (₹)',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  prefixText: '₹ ',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildTextField(
                  controller: _mrpController,
                  label: 'MRP (₹)',
                  hint: '0.00',
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
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildUnitDropdown()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minOrderController,
                  label: 'Min Order Qty',
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildTextField(
                  controller: _prepTimeController,
                  label: 'Prep Time (min)',
                  hint: '30',
                  keyboardType: TextInputType.number,
                  suffixText: 'min',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Set MRP higher than selling price to show discount to customers',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
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
          _sectionHeader('Images'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(3, (i) => _buildImageSlot(i)),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionHeader('Additional Details'),
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
                    Text('Organic Product',
                        style: AppTextStyles.bodyMedium),
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
          _sectionHeader('Tags'),
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
            hint: 'tomato, fresh, organic (comma separated)',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: index < 2 ? AppSpacing.sm : 0),
        child: GestureDetector(
          onTap: () {
            // TODO: open image picker
            setState(() => _imageSlots[index] = true);
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: _imageSlots[index]
                  ? AppColors.primaryContainer
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _imageSlots[index]
                    ? AppColors.primary
                    : AppColors.border,
                style: _imageSlots[index]
                    ? BorderStyle.solid
                    : BorderStyle.solid,
                width: _imageSlots[index] ? 1.5 : 1,
              ),
            ),
            child: _imageSlots[index]
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
                          onTap: () =>
                              setState(() => _imageSlots[index] = false),
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
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.textHint, size: 28),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        index == 0 ? 'Main Photo' : 'Photo ${index + 1}',
                        style: AppTextStyles.labelSmall,
                      ),
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
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _currentStep < 2 ? _nextStep : _submitProduct,
                child: Text(_currentStep < 2 ? 'Next Step' : 'Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleLarge);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      onChanged: (v) => setState(() => _selectedUnit = v!),
      style: AppTextStyles.bodyMedium,
      decoration: const InputDecoration(labelText: 'Unit'),
      items: _units
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
