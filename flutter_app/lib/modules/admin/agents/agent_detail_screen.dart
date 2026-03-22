import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/agents/agent_track_screen.dart';
import '../admin_controller.dart';

class AgentDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? agent;
  const AgentDetailScreen({super.key, this.agent});

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  final controller = Get.find<AdminController>();
  late Map<String, dynamic> _agent;

  @override
  void initState() {
    super.initState();
    _agent = widget.agent ?? Get.arguments?['agent'] ?? {};
  }

  // Fallback / historical data (can be fetched via API later)
  final _currentAssignment = {
    'orderId': 'GB2024091',
    'customerAddress': '42 MG Road, Koramangala, Bangalore',
  };

  final List<dynamic> _deliveryHistory = [];
  final List<dynamic> _documents = [
    {'name': "Driver's License", 'status': 'Verified', 'docNo': 'KA10-2019-1234567'},
    {'name': 'Aadhar Card', 'status': 'Verified', 'docNo': 'XXXX-XXXX-4532'},
    {'name': 'Vehicle RC', 'status': 'Pending', 'docNo': 'KA01AB1234'},
  ];

  Color _docStatusColor(String status) {
    return status == 'Verified' ? AppColors.success : AppColors.warning;
  }

  void _showConfirmDialog(BuildContext context, String action) {
    bool isApprove = action == 'Verify' || action == 'Approve';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('$action Agent?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to $action ${(_agent['name'] ?? 'this agent')}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.success : AppColors.error,
            ),
            onPressed: () async {
              try {
                await controller.verifyAgent(_agent['_id'], isApprove);
                setState(() {
                  _agent['status'] = isApprove ? 'Active' : 'Suspended';
                });
                Navigator.pop(ctx);
                Get.snackbar('Done', '${_agent['name']} has been ${action.toLowerCase()}d.',
                    backgroundColor: isApprove ? AppColors.success : AppColors.error, colorText: Colors.white);
              } catch (e) {
                Get.snackbar('Error', 'Failed to update agent status');
              }
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_agent.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Agent Details')),
        body: const Center(child: Text('Agent data not found')),
      );
    }

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
    final nameStr = _agent['name']?.toString() ?? 'Agent';
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
                    nameStr.substring(0, nameStr.length > 1 ? 2 : 1).toUpperCase(),
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
                      color: _agent['status'] == 'Active' ? AppColors.success : AppColors.error,
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
                  Text(nameStr, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_agent['phone']?.toString() ?? 'N/A', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Joined ${_agent['createdAt']?.toString().split('T')[0] ?? 'N/A'}', style: AppTextStyles.bodySmall),
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
                      _agent['vehicleType']?.toString() ?? 'Two-wheeler',
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
      {'label': 'Deliveries', 'value': _agent['totalDeliveries']?.toString() ?? '0', 'icon': Icons.delivery_dining, 'color': AppColors.primary},
      {'label': 'Rating', 'value': _agent['rating']?.toString() ?? '0.0', 'icon': Icons.star, 'color': AppColors.secondary},
      {'label': 'Earnings (Mo.)', 'value': '₹${_agent['monthlyEarnings']?.toString() ?? '0'}', 'icon': Icons.currency_rupee, 'color': AppColors.success},
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
    final status = _agent['status'] ?? 'Pending';
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
                    onPressed: () => _showConfirmDialog(context, status == 'Suspended' ? 'Unsuspend' : 'Suspend'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: status == 'Suspended' ? AppColors.success : AppColors.error,
                      side: BorderSide(color: status == 'Suspended' ? AppColors.success : AppColors.error),
                    ),
                    child: Text(status == 'Suspended' ? 'Unsuspend' : 'Suspend'),
                  ),
                ),
                if (status == 'Pending') ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(context, 'Verify'),
                      child: const Text('Verify'),
                    ),
                  ),
                ],
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
            if (_deliveryHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text('No delivery history found', style: TextStyle(color: AppColors.textHint)),
              )
            else
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
