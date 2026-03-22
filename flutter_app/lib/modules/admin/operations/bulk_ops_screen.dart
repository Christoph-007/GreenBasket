import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class BulkOpsScreen extends StatefulWidget {
  const BulkOpsScreen({super.key});

  @override
  State<BulkOpsScreen> createState() => _BulkOpsScreenState();
}

class _BulkOpsScreenState extends State<BulkOpsScreen> {
  final Map<String, double?> _runningOps = {};

  final _operations = [
    {
      'id': 'import_products',
      'icon': Icons.upload_file,
      'title': 'Import Products',
      'description': 'Upload a CSV file to bulk import products across all merchants.',
      'color': AppColors.info,
      'actionLabel': 'Upload CSV',
    },
    {
      'id': 'export_orders',
      'icon': Icons.download_rounded,
      'title': 'Export All Orders',
      'description': 'Select a date range and download orders as an Excel file.',
      'color': AppColors.success,
      'actionLabel': 'Export',
    },
    {
      'id': 'update_prices',
      'icon': Icons.price_change_outlined,
      'title': 'Update Prices',
      'description': 'Apply a percentage price change across a category of products.',
      'color': AppColors.secondary,
      'actionLabel': 'Update',
    },
    {
      'id': 'mass_notification',
      'icon': Icons.notifications_outlined,
      'title': 'Send Mass Notification',
      'description': 'Send push notifications to all users, merchants, or agents.',
      'color': AppColors.primary,
      'actionLabel': 'Send',
    },
    {
      'id': 'deactivate_products',
      'icon': Icons.inventory_2_outlined,
      'title': 'Bulk Deactivate Products',
      'description': 'Deactivate all out-of-stock products across the platform.',
      'color': AppColors.warning,
      'actionLabel': 'Run',
    },
    {
      'id': 'generate_reports',
      'icon': Icons.bar_chart,
      'title': 'Generate Reports',
      'description': 'Generate comprehensive platform performance and financial reports.',
      'color': AppColors.primaryDark,
      'actionLabel': 'Generate',
    },
  ];

  void _runOperation(String id, String title) {
    setState(() => _runningOps[id] = 0.0);

    // Simulate progress — replace with actual operation API call
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return false;
      final current = _runningOps[id] ?? 0;
      if (current >= 1.0) {
        setState(() => _runningOps.remove(id));
        Get.snackbar('Done', '$title completed successfully.',
            backgroundColor: AppColors.success, colorText: Colors.white);
        return false;
      }
      setState(() => _runningOps[id] = current + 0.1);
      return true;
    });
  }

  void _showOperationDialog(Map<String, dynamic> op) {
    final id = op['id'] as String;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Row(
          children: [
            Icon(op['icon'] as IconData, color: op['color'] as Color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(op['title'] as String, style: AppTextStyles.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(op['description'] as String, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            if (id == 'export_orders' || id == 'update_prices') ...[
              if (id == 'export_orders') ...[
                const Text('Date Range', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Start Date'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('End Date'),
                      ),
                    ),
                  ],
                ),
              ],
              if (id == 'update_prices') ...[
                const Text('Price Change', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Percentage change',
                    suffixText: '%',
                    hintText: 'e.g. 5 for +5%, -5 for -5%',
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This operation cannot be undone. Please ensure you have a backup.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: op['color'] as Color),
            onPressed: () {
              Navigator.pop(ctx);
              _runOperation(id, op['title'] as String);
            },
            child: Text(op['actionLabel'] as String),
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
        title: const Text('Bulk Operations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.85,
          ),
          itemCount: _operations.length,
          itemBuilder: (_, i) => _buildOpCard(_operations[i]),
        ),
      ),
    );
  }

  Widget _buildOpCard(Map<String, dynamic> op) {
    final id = op['id'] as String;
    final color = op['color'] as Color;
    final isRunning = _runningOps.containsKey(id);
    final progress = _runningOps[id] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(op['icon'] as IconData, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(op['title'] as String, style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                op['description'] as String,
                style: AppTextStyles.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isRunning) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Running...', style: AppTextStyles.labelSmall.copyWith(color: color)),
                  Text('${(progress * 100).toInt()}%', style: AppTextStyles.labelSmall.copyWith(color: color)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showOperationDialog(op),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                  child: Text(op['actionLabel'] as String),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
