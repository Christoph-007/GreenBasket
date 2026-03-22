import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/agents/agent_track_screen.dart';

class AgentDetailScreen extends StatelessWidget {
  const AgentDetailScreen({super.key});

  // Mock agent data — replace with API call
  static const _agent = {
    'name': 'Ravi Kumar',
    'phone': '+91 76543 21098',
    'joinDate': '10 Jan 2024',
    'vehicle': 'Two-wheeler',
    'status': 'Active',
    'deliveries': '342',
    'rating': '4.8',
    'earnings': '₹12,400',
    'activeSince': '10 Jan 2024',
  };

  static const _currentAssignment = {
    'orderId': 'GB2024091',
    'customerAddress': '42 MG Road, Koramangala, Bangalore',
  };

  static final _deliveryHistory = [
    {'orderId': 'GB2024089', 'date': 'Today, 11:45 AM', 'amount': '₹540', 'rating': 5},
    {'orderId': 'GB2024082', 'date': 'Yesterday, 3:20 PM', 'amount': '₹320', 'rating': 4},
    {'orderId': 'GB2024075', 'date': '18 Mar', 'amount': '₹1,200', 'rating': 5},
    {'orderId': 'GB2024068', 'date': '17 Mar', 'amount': '₹450', 'rating': 4},
    {'orderId': 'GB2024062', 'date': '16 Mar', 'amount': '₹680', 'rating': 5},
  ];

  static final _documents = [
    {'name': "Driver's License", 'status': 'Verified', 'docNo': 'KA10-2019-1234567'},
    {'name': 'Aadhar Card', 'status': 'Verified', 'docNo': 'XXXX-XXXX-4532'},
    {'name': 'Vehicle RC', 'status': 'Pending', 'docNo': 'KA01AB1234'},
  ];

  Color _docStatusColor(String status) {
    return status == 'Verified' ? AppColors.success : AppColors.warning;
  }

  void _showConfirmDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('$action Agent?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to $action ${_agent['name']}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Suspend' ? AppColors.error : AppColors.primary,
            ),
            onPressed: () {
              // TODO: Call API to suspend/verify agent
              Navigator.pop(ctx);
              Get.snackbar('Done', '${_agent['name']} has been ${action.toLowerCase()}d.',
                  backgroundColor: AppColors.primary, colorText: Colors.white);
            },
            child: Text(action),
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
        title: const Text('Agent Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildStatsRow(),
            const SizedBox(height: AppSpacing.md),
            _buildDocuments(),
            const SizedBox(height: AppSpacing.md),
            _buildCurrentAssignment(),
            const SizedBox(height: AppSpacing.md),
            _buildActionButtons(context),
            const SizedBox(height: AppSpacing.md),
            _buildDeliveryHistory(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    _agent['name']!.substring(0, 2).toUpperCase(),
                    style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_agent['name']!, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_agent['phone']!, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Joined ${_agent['joinDate']}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _agent['vehicle']!,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Deliveries', 'value': _agent['deliveries']!, 'icon': Icons.delivery_dining, 'color': AppColors.primary},
      {'label': 'Rating', 'value': _agent['rating']!, 'icon': Icons.star, 'color': AppColors.secondary},
      {'label': 'Earnings (Mo.)', 'value': _agent['earnings']!, 'icon': Icons.currency_rupee, 'color': AppColors.success},
    ];
    return Row(
      children: stats.map((s) {
        final color = s['color'] as Color;
        return Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 8),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: color, size: 20),
                  const SizedBox(height: 4),
                  Text(s['value'] as String, style: AppTextStyles.titleMedium.copyWith(color: color)),
                  Text(s['label'] as String, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocuments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documents', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._documents.asMap().entries.map((e) {
              final i = e.key;
              final doc = e.value;
              final status = doc['status']!;
              return Column(
                children: [
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          status == 'Verified' ? Icons.verified_outlined : Icons.hourglass_empty,
                          color: _docStatusColor(status),
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['name']!, style: AppTextStyles.labelLarge),
                              Text(doc['docNo']!, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _docStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            status,
                            style: AppTextStyles.labelSmall.copyWith(color: _docStatusColor(status)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAssignment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Assignment', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${_currentAssignment['orderId']}',
                            style: AppTextStyles.labelLarge),
                        Text(_currentAssignment['customerAddress']!,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Actions', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showConfirmDialog(context, 'Suspend'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Suspend'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmDialog(context, 'Verify'),
                    child: const Text('Verify'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const AgentTrackScreen()),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    child: const Text('Track Live'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Deliveries', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._deliveryHistory.asMap().entries.map((e) {
              final i = e.key;
              final del = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#${del['orderId']}', style: AppTextStyles.labelLarge),
                              Text(del['date'] as String, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(del['amount'] as String, style: AppTextStyles.titleMedium),
                        const SizedBox(width: AppSpacing.sm),
                        Row(
                          children: List.generate(
                            del['rating'] as int,
                            (_) => const Icon(Icons.star, size: 12, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
