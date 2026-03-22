import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // General
  final _appNameController = TextEditingController(text: 'GreenBasket');
  final _supportEmailController = TextEditingController(text: 'support@greenbasket.in');
  final _supportPhoneController = TextEditingController(text: '+91 1800 123 4567');

  // Payment
  bool _codEnabled = true;
  bool _walletEnabled = true;
  bool _upiEnabled = true;
  final _minOrderController = TextEditingController(text: '100');

  // Delivery
  final _deliveryChargeController = TextEditingController(text: '30');
  final _freeDeliveryThresholdController = TextEditingController(text: '500');
  final _maxRadiusController = TextEditingController(text: '10');

  // Notifications
  bool _fcmEnabled = true;
  bool _emailNotifEnabled = true;

  // Security
  final _sessionTimeoutController = TextEditingController(text: '30');
  bool _twoFaEnabled = false;

  @override
  void dispose() {
    _appNameController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _minOrderController.dispose();
    _deliveryChargeController.dispose();
    _freeDeliveryThresholdController.dispose();
    _maxRadiusController.dispose();
    _sessionTimeoutController.dispose();
    super.dispose();
  }

  void _saveSection(String section) {
    // TODO: Call API to save specific settings section
    Get.snackbar('Saved', '$section settings have been updated.',
        backgroundColor: AppColors.success, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Platform Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildGeneralSection(),
            const SizedBox(height: AppSpacing.md),
            _buildPaymentSection(),
            const SizedBox(height: AppSpacing.md),
            _buildDeliverySection(),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationsSection(),
            const SizedBox(height: AppSpacing.md),
            _buildSecuritySection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }

  Widget _buildSaveButton(String section) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => _saveSection(section),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        ),
        child: Text('Save $section'),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General', Icons.settings_outlined),
            const Divider(height: AppSpacing.lg),
            _textField(_appNameController, 'App Name', Icons.apps),
            const SizedBox(height: AppSpacing.md),
            _textField(_supportEmailController, 'Support Email', Icons.email_outlined,
                inputType: TextInputType.emailAddress),
            const SizedBox(height: AppSpacing.md),
            _textField(_supportPhoneController, 'Support Phone', Icons.phone_outlined,
                inputType: TextInputType.phone),
            const SizedBox(height: AppSpacing.md),
            _buildSaveButton('General'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Payment', Icons.payment_outlined),
            const Divider(height: AppSpacing.lg),
            _toggleRow('Cash on Delivery (COD)', _codEnabled, (v) => setState(() => _codEnabled = v)),
            const Divider(),
            _toggleRow('Wallet Payments', _walletEnabled, (v) => setState(() => _walletEnabled = v)),
            const Divider(),
            _toggleRow('UPI Payments', _upiEnabled, (v) => setState(() => _upiEnabled = v)),
            const Divider(height: AppSpacing.lg),
            _textField(_minOrderController, 'Minimum Order Amount (₹)', Icons.currency_rupee,
                inputType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            _buildSaveButton('Payment'),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Delivery', Icons.delivery_dining_outlined),
            const Divider(height: AppSpacing.lg),
            _textField(_deliveryChargeController, 'Default Delivery Charge (₹)', Icons.currency_rupee,
                inputType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            _textField(_freeDeliveryThresholdController, 'Free Delivery Threshold (₹)', Icons.local_shipping_outlined,
                inputType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            _textField(_maxRadiusController, 'Max Delivery Radius (km)', Icons.radar,
                inputType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            _buildSaveButton('Delivery'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Notifications', Icons.notifications_outlined),
            const Divider(height: AppSpacing.lg),
            _toggleRow('FCM Push Notifications', _fcmEnabled, (v) => setState(() => _fcmEnabled = v)),
            const Divider(),
            _toggleRow('Email Notifications', _emailNotifEnabled, (v) => setState(() => _emailNotifEnabled = v)),
            const SizedBox(height: AppSpacing.md),
            _buildSaveButton('Notifications'),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Security', Icons.security_outlined),
            const Divider(height: AppSpacing.lg),
            _textField(_sessionTimeoutController, 'Session Timeout (minutes)', Icons.timer_outlined,
                inputType: TextInputType.number),
            const Divider(height: AppSpacing.lg),
            _toggleRow('Two-Factor Authentication (2FA)', _twoFaEnabled,
                (v) => setState(() => _twoFaEnabled = v)),
            const SizedBox(height: AppSpacing.md),
            _buildSaveButton('Security'),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
