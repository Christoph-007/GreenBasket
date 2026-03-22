import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_app_bar.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  static const _tiers = [
    {'name': 'Bronze', 'min': 0, 'max': 999, 'color': Color(0xFF8D6E63)},
    {'name': 'Silver', 'min': 1000, 'max': 4999, 'color': Color(0xFF9E9E9E)},
    {'name': 'Gold', 'min': 5000, 'max': 9999, 'color': Color(0xFFFFC107)},
    {'name': 'Platinum', 'min': 10000, 'max': 99999, 'color': Color(0xFF7B1FA2)},
  ];

  @override
  Widget build(BuildContext context) {
    const points = 320;
    const tier = 'bronze';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'Loyalty Points'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'My Points',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          AppHelpers.getLoyaltyTierLabel(tier),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '$points',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress to next tier
            Text('Tier Progress', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bronze', style: AppTextStyles.bodyMedium),
                      Text('Silver (1000 pts)', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: points / 1000,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${1000 - points} more points to reach Silver',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tiers overview
            Text('Tier Benefits', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            ..._tiers.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: tier ==
                              (t['name'] as String).toLowerCase()
                          ? t['color'] as Color
                          : AppColors.border,
                      width: tier == (t['name'] as String).toLowerCase() ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, color: t['color'] as Color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['name'] as String,
                                style: AppTextStyles.titleMedium),
                            Text(
                              '${t['min']} – ${t['max']} points',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (tier == (t['name'] as String).toLowerCase())
                        const Text('Current',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
