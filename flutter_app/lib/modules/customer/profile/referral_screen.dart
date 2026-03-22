import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../modules/auth/auth_controller.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/gb_button.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final code = authCtrl.user.value?.referralCode ?? 'GB12345';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'Refer & Earn'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.people_outline,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Invite Friends & Earn', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Share your referral code and earn ₹100 wallet credit for each friend who makes their first order.',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Get.snackbar('Copied', 'Referral code copied!',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Icon(Icons.copy_outlined,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GBButton(
              label: 'Share Referral Code',
              onPressed: () {},
              isFullWidth: true,
              leadingIcon: Icons.share_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
