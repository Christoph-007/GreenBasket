import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/giftcards/generate_gift_card_screen.dart';

class GiftCardsAdminScreen extends StatefulWidget {
  const GiftCardsAdminScreen({super.key});

  @override
  State<GiftCardsAdminScreen> createState() => _GiftCardsAdminScreenState();
}

class _GiftCardsAdminScreenState extends State<GiftCardsAdminScreen> {
  String _statusFilter = 'All';
  final _statusFilters = ['All', 'Active', 'Redeemed', 'Expired'];

  // Mock gift cards — replace with API call
  final _giftCards = [
    {
      'code': 'GB-GIFT-X7K2',
      'value': '₹1,000',
      'balance': '₹1,000',
      'issuedTo': 'priya@email.com',
      'issuedDate': '15 Mar 2024',
      'expiry': '15 Jun 2024',
      'status': 'Active',
    },
    {
      'code': 'GB-GIFT-M3N9',
      'value': '₹500',
      'balance': '₹0',
      'issuedTo': 'amit@email.com',
      'issuedDate': '10 Mar 2024',
      'expiry': '10 Jun 2024',
      'status': 'Redeemed',
    },
    {
      'code': 'GB-GIFT-P8Q1',
      'value': '₹2,000',
      'balance': '₹1,200',
      'issuedTo': 'neha@email.com',
      'issuedDate': '01 Mar 2024',
      'expiry': '01 Jun 2024',
      'status': 'Active',
    },
    {
      'code': 'GB-GIFT-L5R4',
      'value': '₹500',
      'balance': '₹0',
      'issuedTo': 'suresh@email.com',
      'issuedDate': '01 Jan 2024',
      'expiry': '01 Apr 2024',
      'status': 'Expired',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Redeemed':
        return AppColors.info;
      default:
        return AppColors.error;
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_statusFilter == 'All') return _giftCards.cast<Map<String, dynamic>>();
    return _giftCards.where((g) => g['status'] == _statusFilter).toList().cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gift Cards'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const GenerateGiftCardScreen()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Generate Gift Card', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStats(),
          _buildFilterChips(),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No gift cards found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildGiftCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final total = _giftCards.length;
    final active = _giftCards.where((g) => g['status'] == 'Active').length;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _stat('Total Issued', '$total', AppColors.textPrimary),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Active Cards', '$active', AppColors.success),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Total Redeemed', '₹3,500', AppColors.info),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final filter = _statusFilters[i];
          final isSelected = _statusFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => setState(() => _statusFilter = filter),
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
          );
        },
      ),
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> card) {
    final status = card['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.primaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(card['code'] as String, style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSmall.copyWith(color: _statusColor(status)),
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Value', style: AppTextStyles.bodySmall),
                        Text(card['value'] as String, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: AppTextStyles.bodySmall),
                        Text(card['balance'] as String, style: AppTextStyles.titleLarge.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(card['issuedTo'] as String, style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Issued: ${card['issuedDate']}', style: AppTextStyles.bodySmall),
                  const SizedBox(width: AppSpacing.md),
                  Text('Expires: ${card['expiry']}', style: AppTextStyles.bodySmall.copyWith(
                    color: status == 'Expired' ? AppColors.error : AppColors.textSecondary,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
