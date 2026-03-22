import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  // Mock payout history — TODO: fetch from API
  static const _payouts = [
    {
      'date': 'Mar 15, 2024',
      'amount': 18500.0,
      'status': 'Processed',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0315',
    },
    {
      'date': 'Mar 1, 2024',
      'amount': 22300.0,
      'status': 'Processed',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0301',
    },
    {
      'date': 'Feb 21, 2024',
      'amount': 12450.0,
      'status': 'Pending',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0221',
    },
    {
      'date': 'Feb 15, 2024',
      'amount': 19800.0,
      'status': 'Processed',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0215',
    },
    {
      'date': 'Feb 1, 2024',
      'amount': 16200.0,
      'status': 'Processed',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0201',
    },
    {
      'date': 'Jan 21, 2024',
      'amount': 9750.0,
      'status': 'Processed',
      'bankLast4': '4521',
      'txnId': 'PAY-2024-0121',
    },
  ];

  void _requestPayout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Request Payout', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Available Balance',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '₹12,450.00',
              style: AppTextStyles.displayMedium
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_outlined,
                      color: AppColors.textSecondary, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bank Account',
                            style: AppTextStyles.bodySmall),
                        Text(
                          'HDFC Bank ····4521',
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Payouts are processed within 2-3 business days',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Payout Requested',
                    '₹12,450 will be credited in 2-3 days',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text('Confirm Payout Request'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payouts'),
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
            // Available balance card (green gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Available Balance',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '₹12,450.00',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next payout',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white54),
                          ),
                          Text(
                            'Apr 1, 2024',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _requestPayout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: Text('Request Payout',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Minimum payout notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Minimum payout amount is ₹500. Platform commission of 10% applies.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Summary stats
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Total Paid Out',
                    '₹99,000',
                    AppColors.success,
                    Icons.arrow_circle_up_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _summaryItem(
                    'Total Payouts',
                    '${_payouts.length}',
                    AppColors.primary,
                    Icons.receipt_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Payout history
            Text('Payout History', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ..._payouts.map(_buildPayoutCard),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.textPrimary)),
                Text(label,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> payout) {
    final isProcessed = payout['status'] == 'Processed';
    final statusColor =
        isProcessed ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isProcessed
                  ? Icons.check_circle_outline
                  : Icons.schedule_outlined,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '₹${(payout['amount'] as double).toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        payout['status'] as String,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(payout['date'] as String,
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'HDFC ····${payout['bankLast4']}',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                payout['txnId'] as String,
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
