import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class _Plan {
  final String id;
  final String name;
  final double pricePerMonth;
  final List<String> benefits;
  final bool isRecommended;
  final bool isFree;

  const _Plan({
    required this.id,
    required this.name,
    required this.pricePerMonth,
    required this.benefits,
    this.isRecommended = false,
    this.isFree = false,
  });
}

const List<_Plan> _plans = [
  _Plan(
    id: 'free',
    name: 'Free',
    pricePerMonth: 0,
    isFree: true,
    benefits: [
      'Standard delivery (₹50)',
      'Basic loyalty points (1x)',
      'Access to all products',
      '1 address saved',
    ],
  ),
  _Plan(
    id: 'silver',
    name: 'Silver',
    pricePerMonth: 99,
    benefits: [
      'Free delivery on orders ≥₹500',
      '1.5x loyalty points',
      'Early access to sales',
      '3 addresses saved',
      'Priority customer support',
    ],
  ),
  _Plan(
    id: 'gold',
    name: 'Gold',
    pricePerMonth: 199,
    isRecommended: true,
    benefits: [
      'Free delivery on all orders',
      '2x loyalty points',
      'Exclusive member-only deals',
      'Unlimited addresses',
      'Dedicated support line',
      'Monthly surprise gift',
    ],
  ),
  _Plan(
    id: 'platinum',
    name: 'Platinum',
    pricePerMonth: 399,
    benefits: [
      'Free express delivery',
      '3x loyalty points',
      'Personal shopper service',
      'Unlimited addresses',
      '24/7 concierge support',
      'Monthly premium gift box',
      'Exclusive recipes & meal plans',
    ],
  ),
];

// Benefits for the comparison table
final List<String> _comparisonBenefits = [
  'Free Delivery',
  'Loyalty Multiplier',
  'Early Sale Access',
  'Priority Support',
  'Monthly Gift',
  'Personal Shopper',
];

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  // Mock: user's current plan is Free
  final String _currentPlanId = 'free';
  String _selectedPlanId = 'gold';

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
        title: const Text('Membership Plans',
            style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current plan header
            _buildCurrentPlanHeader(),
            const SizedBox(height: AppSpacing.lg),

            // Plan cards
            const Text('Choose a Plan',
                style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(_plans.length, (i) {
              final plan = _plans[i];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildPlanCard(plan),
              );
            }),
            const SizedBox(height: AppSpacing.xl),

            // Subscribe button
            if (_selectedPlanId != _currentPlanId) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final plan = _plans.firstWhere(
                        (p) => p.id == _selectedPlanId);
                    // TODO: Initiate subscription purchase
                    Get.snackbar(
                      'Subscription',
                      'Upgrading to ${plan.name} plan...',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Subscribe to ${_plans.firstWhere((p) => p.id == _selectedPlanId).name} Plan',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Cancel anytime. No hidden fees.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Comparison table
            _buildComparisonTable(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanHeader() {
    final currentPlan =
        _plans.firstWhere((p) => p.id == _currentPlanId);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Plan',
                    style: AppTextStyles.bodySmall),
                Text(currentPlan.name,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(_Plan plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isCurrent = _currentPlanId == plan.id;
    final isGold = plan.id == 'gold';

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isGold && isSelected
              ? null
              : AppColors.surface,
          gradient: isGold && isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected && !isGold
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  // Plan name
                  Text(
                    plan.name,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isGold && isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (plan.isRecommended) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isGold && isSelected
                            ? Colors.white.withOpacity(0.25)
                            : AppColors.secondary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isGold && isSelected
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (isCurrent) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Current',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isGold && isSelected
                              ? Colors.white
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Price
                  plan.isFree
                      ? Text(
                          'Free',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: isGold && isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '₹${plan.pricePerMonth.toInt()}',
                                style:
                                    AppTextStyles.displayMedium.copyWith(
                                  color: isGold && isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: '/mo',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isGold && isSelected
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: plan.benefits.map((b) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: isGold && isSelected
                              ? Colors.white70
                              : AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            b,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isGold && isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text('Benefits Comparison',
                style: AppTextStyles.titleLarge),
          ),
          const Divider(height: 1),
          // Header row
          _TableRow(
            cells: [
              const Text('Feature',
                  style: AppTextStyles.labelLarge),
              ..._plans.map((p) => Text(
                    p.name,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  )),
            ],
            isHeader: true,
          ),
          const Divider(height: 1),
          // Rows
          ..._comparisonBenefits.asMap().entries.map((entry) {
            final i = entry.key;
            final benefit = entry.value;
            final hasValues = [
              [false, true, true, true],
              ['1x', '1.5x', '2x', '3x'],
              [false, true, true, true],
              [false, true, true, true],
              [false, false, true, true],
              [false, false, false, true],
            ];
            return Column(
              children: [
                _TableRow(
                  cells: [
                    Text(benefit,
                        style: AppTextStyles.bodySmall),
                    ...hasValues[i].map((v) {
                      if (v is bool) {
                        return Icon(
                          v
                              ? Icons.check_rounded
                              : Icons.remove_rounded,
                          size: 16,
                          color: v
                              ? AppColors.success
                              : AppColors.textHint,
                        );
                      } else {
                        return Text(
                          v.toString(),
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        );
                      }
                    }),
                  ],
                ),
                if (i < _comparisonBenefits.length - 1)
                  const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<Widget> cells;
  final bool isHeader;
  const _TableRow({required this.cells, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isHeader ? AppColors.surfaceVariant : null,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: cells.asMap().entries.map((e) {
          return Expanded(
            flex: e.key == 0 ? 2 : 1,
            child: Align(
              alignment: e.key == 0
                  ? Alignment.centerLeft
                  : Alignment.center,
              child: e.value,
            ),
          );
        }).toList(),
      ),
    );
  }
}
