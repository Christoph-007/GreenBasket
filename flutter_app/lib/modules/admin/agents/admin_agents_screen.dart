import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/agents/agent_detail_screen.dart';

class AdminAgentsScreen extends StatefulWidget {
  const AdminAgentsScreen({super.key});

  @override
  State<AdminAgentsScreen> createState() => _AdminAgentsScreenState();
}

class _AdminAgentsScreenState extends State<AdminAgentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock agents data — replace with API call
  final _agents = [
    {
      'id': 'A001', 'name': 'Ravi Kumar', 'phone': '+91 76543 21098',
      'vehicle': 'Two-wheeler', 'rating': 4.8, 'deliveries': 342,
      'status': 'Active', 'tab': 0,
    },
    {
      'id': 'A002', 'name': 'Suresh Sharma', 'phone': '+91 87654 32109',
      'vehicle': 'Three-wheeler', 'rating': 4.5, 'deliveries': 210,
      'status': 'Active', 'tab': 0,
    },
    {
      'id': 'A003', 'name': 'Mohan Das', 'phone': '+91 98765 43210',
      'vehicle': 'Two-wheeler', 'rating': 0.0, 'deliveries': 0,
      'status': 'Pending', 'tab': 2,
    },
    {
      'id': 'A004', 'name': 'Pradeep Singh', 'phone': '+91 65432 10987',
      'vehicle': 'Bicycle', 'rating': 4.2, 'deliveries': 89,
      'status': 'Suspended', 'tab': 3,
    },
    {
      'id': 'A005', 'name': 'Vijay Menon', 'phone': '+91 54321 09876',
      'vehicle': 'Two-wheeler', 'rating': 0.0, 'deliveries': 0,
      'status': 'Pending', 'tab': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _agentsForTab(int tab) {
    if (tab == 0) return _agents.cast<Map<String, dynamic>>();
    return _agents.where((a) => a['tab'] == tab).toList().cast<Map<String, dynamic>>();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Agents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Suspended'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatsRow(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2, 3].map((tab) {
                final agents = _agentsForTab(tab);
                return agents.isEmpty
                    ? const Center(child: Text('No agents in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: agents.length,
                        itemBuilder: (_, i) => _buildAgentCard(agents[i]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _agents.length;
    final active = _agents.where((a) => a['status'] == 'Active').length;
    final pending = _agents.where((a) => a['status'] == 'Pending').length;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _stat('Total Agents', '$total', AppColors.textPrimary),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Active Now', '$active', AppColors.success),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Pending Verification', '$pending', AppColors.warning),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final status = agent['status'] as String;
    final rating = agent['rating'] as double;
    final vehicle = agent['vehicle'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => Get.to(() => const AgentDetailScreen()),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      (agent['name'] as String).substring(0, 2).toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _statusColor(status),
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
                    Text(agent['name'] as String, style: AppTextStyles.titleMedium),
                    Text(agent['phone'] as String, style: AppTextStyles.bodySmall),
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
                        if (rating > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.star, size: 12, color: AppColors.secondary),
                          Text(' $rating', style: AppTextStyles.bodySmall),
                        ],
                        if ((agent['deliveries'] as int) > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.delivery_dining, size: 12, color: AppColors.textSecondary),
                          Text(' ${agent['deliveries']}', style: AppTextStyles.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: _statusColor(status)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
