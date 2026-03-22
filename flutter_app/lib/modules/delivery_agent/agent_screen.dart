import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../modules/auth/auth_controller.dart';

class AgentCurrentJobScreen extends StatelessWidget {
  const AgentCurrentJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Agent', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delivery_dining_outlined,
                size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Delivery Agent Panel', style: AppTextStyles.headlineLarge),
            SizedBox(height: 8),
            Text(
              'Coming soon — delivery agent panel\nfor jobs, earnings & tracking',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
