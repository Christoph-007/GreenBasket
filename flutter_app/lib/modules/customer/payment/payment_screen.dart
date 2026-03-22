import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/config/routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'card';
  bool _showAddCard = false;

  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();

  // Mock order data — replace with actual args from Get.arguments in production
  final double _subtotal = 435.00;
  final double _delivery = 50.00;
  final double _total = 485.00;
  // Mock wallet balance — shown in payment option subtitle
  // final double _walletBalance = 250.00;

  final List<_PaymentOption> _paymentOptions = [
    _PaymentOption(
      id: 'card',
      label: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, RuPay',
      icon: Icons.credit_card_rounded,
    ),
    _PaymentOption(
      id: 'upi',
      label: 'UPI',
      subtitle: 'GPay, PhonePe, Paytm, BHIM',
      icon: Icons.account_balance_rounded,
    ),
    _PaymentOption(
      id: 'wallet',
      label: 'GreenBasket Wallet',
      subtitle: 'Balance: ₹250.00',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _PaymentOption(
      id: 'cod',
      label: 'Cash on Delivery',
      subtitle: 'Pay when your order arrives',
      icon: Icons.money_rounded,
    ),
  ];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  void _onPay() {
    // TODO: Integrate payment gateway (Stripe / Razorpay / UPI) here
    Get.offAllNamed(Routes.orderList);
    Get.snackbar(
      'Payment Successful',
      'Your order has been placed!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Select Payment Method',
            style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment options
                  ..._paymentOptions.map((option) => _buildPaymentCard(option)),

                  const SizedBox(height: AppSpacing.md),

                  // Add New Card expandable
                  if (_selectedMethod == 'card') ...[
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showAddCard = !_showAddCard),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.add_card_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Expanded(
                              child: Text('Add New Card',
                                  style: AppTextStyles.titleMedium),
                            ),
                            AnimatedRotation(
                              turns: _showAddCard ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _showAddCard
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildAddCardForm(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Order summary
                  const Text('Order Summary',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Subtotal',
                            '₹${_subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryRow('Delivery Fee',
                            '₹${_delivery.toStringAsFixed(2)}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          child: Divider(height: 1),
                        ),
                        _SummaryRow(
                          'Total',
                          '₹${_total.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // Pay Now button
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, -2)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Pay Now  ₹${_total.toStringAsFixed(2)}',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(_PaymentOption option) {
    final isSelected = _selectedMethod == option.id;
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedMethod = option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(option.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      )),
                  Text(option.subtitle,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Radio<String>(
              value: option.id,
              groupValue: _selectedMethod,
              onChanged: (v) =>
                  setState(() => _selectedMethod = v ?? option.id),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardForm() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Card Details',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _cardNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _cardNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Expiry (MM/YY)',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    hintText: 'MM/YY',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _cvvCtrl,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: '•••',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.lock_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Your card data is encrypted and secure',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  const _PaymentOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style =
        isBold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(
              color: isBold ? AppColors.primary : AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text =
        newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection:
          TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length == 2 && oldValue.text.length == 1) {
      final formatted = '$text/';
      return newValue.copyWith(
        text: formatted,
        selection:
            TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
