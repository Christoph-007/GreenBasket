import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/config/routes.dart';

class _AddressData {
  final String id;
  final String label;
  final String addressLine;
  final String city;
  final String pincode;
  bool isDefault;

  _AddressData({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.pincode,
    this.isDefault = false,
  });
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  // Mock data — in production load from API
  final List<_AddressData> _addresses = [
    _AddressData(
      id: '1',
      label: 'Home',
      addressLine: '42, Sunshine Apartments, MG Road',
      city: 'Bengaluru',
      pincode: '560001',
      isDefault: true,
    ),
    _AddressData(
      id: '2',
      label: 'Work',
      addressLine: '14th Floor, Prestige Tech Park, Outer Ring Road',
      city: 'Bengaluru',
      pincode: '560037',
    ),
    _AddressData(
      id: '3',
      label: 'Other',
      addressLine: 'Plot 7, Sector 18, NOIDA',
      city: 'NOIDA',
      pincode: '201301',
    ),
  ];

  void _setDefault(String id) {
    setState(() {
      for (final a in _addresses) {
        a.isDefault = a.id == id;
      }
    });
  }

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Delete Address',
            style: AppTextStyles.titleLarge),
        content: const Text(
            'Are you sure you want to delete this address?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              setState(
                  () => _addresses.removeWhere((a) => a.id == id));
              Get.snackbar('Deleted', 'Address removed',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Addresses',
            style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary),
            onPressed: () => Get.toNamed('${Routes.addresses}/add'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: _addresses.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) =>
                  _buildAddressCard(_addresses[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('${Routes.addresses}/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Add New Address',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(_AddressData address) {
    final isHome = address.label == 'Home';
    final isWork = address.label == 'Work';

    Color labelColor = AppColors.textSecondary;
    Color labelBg = AppColors.surfaceVariant;
    IconData labelIcon = Icons.location_on_rounded;
    if (isHome) {
      labelColor = AppColors.primary;
      labelBg = AppColors.primaryContainer;
      labelIcon = Icons.home_rounded;
    } else if (isWork) {
      labelColor = AppColors.info;
      labelBg = const Color(0xFFE3F2FD);
      labelIcon = Icons.work_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primary
              : AppColors.border,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Label badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius:
                      BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(labelIcon, size: 12, color: labelColor),
                    const SizedBox(width: 4),
                    Text(
                      address.label,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: labelColor),
                    ),
                  ],
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
              const Spacer(),
              // Edit
              _IconBtn(
                icon: Icons.edit_outlined,
                color: AppColors.textSecondary,
                onTap: () {
                  // TODO: Navigate to edit address screen with address id
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              // Delete
              _IconBtn(
                icon: Icons.delete_outline_rounded,
                color: AppColors.error,
                onTap: () => _delete(address.id),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.addressLine,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            '${address.city} – ${address.pincode}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!address.isDefault)
            GestureDetector(
              onTap: () => _setDefault(address.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radio_button_off_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Set as default',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('No addresses saved',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your delivery addresses for faster checkout',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
