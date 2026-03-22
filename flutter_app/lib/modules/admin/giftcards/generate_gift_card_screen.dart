import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class GenerateGiftCardScreen extends StatefulWidget {
  const GenerateGiftCardScreen({super.key});

  @override
  State<GenerateGiftCardScreen> createState() => _GenerateGiftCardScreenState();
}

class _GenerateGiftCardScreenState extends State<GenerateGiftCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _customAmountController = TextEditingController();

  int? _selectedValue;
  int _selectedExpiry = 1; // index
  int _quantity = 1;
  bool _useCustomAmount = false;

  final _presetValues = [500, 1000, 2000, 5000];
  final _expiryOptions = ['3 Months', '6 Months', '1 Year'];

  void _generate() {
    if (_formKey.currentState!.validate()) {
      final value = _useCustomAmount
          ? int.tryParse(_customAmountController.text) ?? 0
          : _selectedValue;
      if (value == null || value == 0) {
        Get.snackbar('Select Amount', 'Please select or enter a gift card value.',
            backgroundColor: AppColors.warning, colorText: Colors.white);
        return;
      }
      // TODO: Call API to generate gift cards
      Get.back();
      Get.snackbar(
        'Gift Cards Generated',
        '$_quantity gift card(s) of ₹$value each have been generated.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generate Gift Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildValueSelector(),
              const SizedBox(height: AppSpacing.md),
              _buildRecipientSection(),
              const SizedBox(height: AppSpacing.md),
              _buildExpirySelector(),
              const SizedBox(height: AppSpacing.md),
              _buildQuantitySection(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generate,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Generate${_quantity > 1 ? ' $_quantity Gift Cards' : ' Gift Card'}'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gift Card Value', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: _presetValues.map((value) {
                final isSelected = !_useCustomAmount && _selectedValue == value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedValue = value;
                        _useCustomAmount = false;
                        _customAmountController.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '₹$value',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Checkbox(
                  value: _useCustomAmount,
                  onChanged: (v) => setState(() {
                    _useCustomAmount = v ?? false;
                    if (_useCustomAmount) _selectedValue = null;
                  }),
                  activeColor: AppColors.primary,
                ),
                const Text('Custom Amount', style: AppTextStyles.bodyMedium),
              ],
            ),
            if (_useCustomAmount)
              TextFormField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '₹',
                ),
                validator: (v) {
                  if (!_useCustomAmount) return null;
                  final amount = int.tryParse(v ?? '');
                  if (amount == null || amount < 100) return 'Minimum amount is ₹100';
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recipient Details', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Send to Email',
                hintText: 'recipient@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personalized Message (Optional)',
                hintText: 'Happy Birthday! Enjoy shopping with GreenBasket.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expiry Period', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _expiryOptions.asMap().entries.map((e) {
                final isSelected = _selectedExpiry == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedExpiry = e.key),
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quantity (Bulk)', style: AppTextStyles.titleLarge),
                  Text('Generate multiple cards at once', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text('$_quantity', style: AppTextStyles.titleLarge),
                ),
                IconButton(
                  onPressed: _quantity < 100 ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
