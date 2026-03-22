import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  // Mock plans — replace with API call
  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'free',
      'name': 'Free',
      'price': '₹0',
      'subscribers': 8420,
      'revenue': '₹0',
      'color': AppColors.textSecondary,
      'benefits': ['Basic ordering', 'Standard delivery', 'Email support'],
    },
    {
      'id': 'silver',
      'name': 'Silver',
      'price': '₹99/mo',
      'subscribers': 1240,
      'revenue': '₹1,22,760',
      'color': const Color(0xFF9E9E9E),
      'benefits': ['Free delivery on orders >₹300', 'Priority support', '5% cashback', 'Early sale access'],
    },
    {
      'id': 'gold',
      'name': 'Gold',
      'price': '₹199/mo',
      'subscribers': 680,
      'revenue': '₹1,35,320',
      'color': AppColors.secondary,
      'benefits': ['Free delivery on all orders', '10% cashback', 'Dedicated support', 'Exclusive deals', 'Recipe access'],
    },
    {
      'id': 'platinum',
      'name': 'Platinum',
      'price': '₹399/mo',
      'subscribers': 210,
      'revenue': '₹83,790',
      'color': AppColors.primary,
      'benefits': ['Free delivery always', '15% cashback', 'VIP support', 'Exclusive products', 'Recipe access', 'Personal shopper'],
    },
  ];

  void _showEditPlanSheet(Map<String, dynamic> plan) {
    final priceController = TextEditingController(text: plan['price'] as String);
    final descController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.full)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Edit ${plan['name']} Plan', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Describe this plan benefits...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Benefits (current)', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              ...(plan['benefits'] as List<String>).map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(b, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Call API to update plan
                    Navigator.pop(ctx);
                    Get.snackbar('Plan Updated', '${plan['name']} plan has been updated.',
                        backgroundColor: AppColors.success, colorText: Colors.white);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Membership Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _plans.length,
        itemBuilder: (_, i) => _buildPlanCard(_plans[i]),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final color = plan['color'] as Color;
    final benefits = plan['benefits'] as List<String>;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    plan['name'] as String,
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(plan['price'] as String, style: AppTextStyles.titleLarge.copyWith(color: color)),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => _showEditPlanSheet(plan),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statChip(
                        Icons.people_outline,
                        '${plan['subscribers']} subscribers',
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _statChip(
                        Icons.currency_rupee,
                        plan['revenue'] as String,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Benefits', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ...benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: color),
                        const SizedBox(width: 8),
                        Text(b, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: color))),
        ],
      ),
    );
  }
}
