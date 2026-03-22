import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AssignOrderScreen extends StatefulWidget {
  const AssignOrderScreen({super.key});

  @override
  State<AssignOrderScreen> createState() => _AssignOrderScreenState();
}

class _AssignOrderScreenState extends State<AssignOrderScreen> {
  String? _selectedAgentId;

  // Mock order info — replace with actual data passed via Get.arguments
  final _order = {
    'id': 'GB2024091',
    'pickup': 'Fresh Farms Organics, MG Road, Bangalore',
    'delivery': '42 MG Road, Koramangala, Bangalore - 560034',
    'distance': '3.2 km',
  };

  // Mock available agents — replace with API call
  final _agents = [
    {
      'id': 'A001',
      'name': 'Ravi Kumar',
      'distance': '0.8 km away',
      'currentDeliveries': 0,
      'rating': 4.8,
      'vehicle': 'Two-wheeler',
    },
    {
      'id': 'A002',
      'name': 'Suresh Sharma',
      'distance': '1.4 km away',
      'currentDeliveries': 1,
      'rating': 4.5,
      'vehicle': 'Three-wheeler',
    },
    {
      'id': 'A006',
      'name': 'Anil Verma',
      'distance': '2.1 km away',
      'currentDeliveries': 0,
      'rating': 4.6,
      'vehicle': 'Two-wheeler',
    },
    {
      'id': 'A007',
      'name': 'Deepak Nair',
      'distance': '2.8 km away',
      'currentDeliveries': 1,
      'rating': 4.3,
      'vehicle': 'Bicycle',
    },
  ];

  Color _vehicleColor(String vehicle) {
    switch (vehicle) {
      case 'Two-wheeler':
        return AppColors.info;
      case 'Three-wheeler':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  void _assignOrder() {
    if (_selectedAgentId == null) {
      Get.snackbar('Select Agent', 'Please select a delivery agent to assign.',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    final agent = _agents.firstWhere((a) => a['id'] == _selectedAgentId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Confirm Assignment', style: AppTextStyles.titleLarge),
        content: Text(
          'Assign order #${_order['id']} to ${agent['name']}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to assign order to agent
              Navigator.pop(ctx);
              Get.back();
              Get.snackbar(
                'Order Assigned',
                'Order #${_order['id']} has been assigned to ${agent['name']}.',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            child: const Text('Assign'),
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
        title: const Text('Assign Delivery Agent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton(
            onPressed: _assignOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Assign Order'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfoCard(),
            const SizedBox(height: AppSpacing.md),
            const Text('Available Agents', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._agents.map((agent) => _buildAgentCard(agent)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Order #${_order['id']}', style: AppTextStyles.titleLarge),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _order['distance']!,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _routeRow(Icons.store_outlined, 'Pickup', _order['pickup']!, AppColors.secondary),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Container(width: 2, height: 16, color: AppColors.border),
            ),
            _routeRow(Icons.location_on_outlined, 'Delivery', _order['delivery']!, AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _routeRow(IconData icon, String type, String address, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.labelSmall.copyWith(color: color)),
              Text(address, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final id = agent['id'] as String;
    final isSelected = _selectedAgentId == id;
    final vehicle = agent['vehicle'] as String;
    final deliveries = agent['currentDeliveries'] as int;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedAgentId = id),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Radio<String>(
                value: id,
                groupValue: _selectedAgentId,
                onChanged: (v) => setState(() => _selectedAgentId = v),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  (agent['name'] as String).substring(0, 2).toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent['name'] as String, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                        Text(agent['distance'] as String, style: AppTextStyles.bodySmall),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.delivery_dining, size: 12, color: AppColors.textSecondary),
                        Text(' $deliveries active', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _vehicleColor(vehicle).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            vehicle,
                            style: AppTextStyles.labelSmall.copyWith(color: _vehicleColor(vehicle)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.star, size: 12, color: AppColors.secondary),
                        Text(' ${agent['rating']}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
