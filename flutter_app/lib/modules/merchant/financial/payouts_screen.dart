import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'payouts_controller.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PayoutsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payouts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available balance card
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
                    Obx(() => Text(
                          '₹${controller.availableBalance.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )),
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
                            Obx(() => Text(
                                  controller.nextPayoutDate.value.isNotEmpty
                                      ? controller.nextPayoutDate.value
                                      : 'To be scheduled',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: Colors.white),
                                )),
                          ],
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isRequesting.value ||
                                      controller.availableBalance.value <= 0
                                  ? null
                                  : () => _confirmPayout(context, controller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                              child: controller.isRequesting.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Text('Request Payout',
                                      style: AppTextStyles.labelLarge
                                          .copyWith(
                                              color: AppColors.primary)),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Info
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
                      Obx(() => Text(
                          '₹${controller.totalPaidOut.value.toStringAsFixed(0)}',
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.success))),
                      AppColors.success,
                      Icons.arrow_circle_up_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _summaryItem(
                      'Total Payouts',
                      Obx(() => Text('${controller.payouts.length}',
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary))),
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
              Obx(() {
                if (controller.payouts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('No payout history found',
                          style: AppTextStyles.bodyMedium),
                    ),
                  );
                }
                return Column(
                  children: controller.payouts
                      .map((p) => _buildPayoutCard(p))
                      .toList(),
                );
              }),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }

  void _confirmPayout(BuildContext context, PayoutsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
            const Text('Available Balance', style: AppTextStyles.bodySmall),
            Obx(() => Text(
                  '₹${controller.availableBalance.value.toStringAsFixed(2)}',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.primary),
                )),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Obx(() => Container(
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
                              controller.bankName.value.isNotEmpty
                                  ? '${controller.bankName.value} ····${controller.bankLast4.value}'
                                  : 'No bank account linked',
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.warning),
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
                  controller.requestPayout();
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

  Widget _summaryItem(
      String label, Widget valueWidget, Color color, IconData icon) {
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
                valueWidget,
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
    final status = payout['status'] ?? 'Pending';
    final isProcessed = status == 'Processed' || status == 'processed';
    final statusColor = isProcessed ? AppColors.success : AppColors.warning;
    final amount = (payout['amount'] ?? 0).toDouble();
    final date = payout['date'] ?? payout['createdAt'] ?? '-';
    final bank = payout['bankName'] ?? '';
    final last4 = payout['bankLast4'] ?? '****';
    final txnId = payout['txnId'] ?? payout['_id'] ?? '-';

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
                      '₹${amount.toStringAsFixed(0)}',
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
                        status,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('$date', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bank.isNotEmpty ? '$bank ····$last4' : '····$last4',
                style: AppTextStyles.bodySmall,
              ),
              Text('$txnId', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
