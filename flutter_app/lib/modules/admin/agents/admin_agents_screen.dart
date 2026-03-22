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
  final controller = Get.find<AdminController>();

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
    if (tab == 0) return controller.agents.cast<Map<String, dynamic>>();
    String statusFilter = '';
    switch (tab) {
      case 1: statusFilter = 'Active'; break;
      case 2: statusFilter = 'Pending'; break;
      case 3: statusFilter = 'Suspended'; break;
    }
    return controller.agents.where((a) => a['status'] == statusFilter).toList().cast<Map<String, dynamic>>();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active': return AppColors.success;
      case 'Pending': return AppColors.warning;
      default: return AppColors.error;
    }
  }

  Color _vehicleColor(String vehicle) {
    switch (vehicle) {
      case 'Two-wheeler': return AppColors.info;
      case 'Three-wheeler': return AppColors.secondary;
      default: return AppColors.primary;
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
      body: Obx(() => Column(
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
      )),
    );
  }

  Widget _buildStatsRow() {
    final total = controller.agents.length;
    final active = controller.agents.where((a) => a['status'] == 'Active').length;
    final pending = controller.agents.where((a) => a['status'] == 'Pending').length;
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
    final status = agent['status'] as String? ?? 'Pending';
    final name = agent['name'] as String? ?? 'Unknown';
    final phone = agent['phone'] as String? ?? 'No phone';
    final rating = (agent['rating'] as num?)?.toDouble() ?? 0.0;
    final vehicle = agent['vehicleType'] as String? ?? 'Two-wheeler';
    final deliveries = agent['totalDeliveries'] as int? ?? 0;

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
                      name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase(),
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
                    Text(name, style: AppTextStyles.titleMedium),
                    Text(phone, style: AppTextStyles.bodySmall),
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
                        if (deliveries > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.delivery_dining, size: 12, color: AppColors.textSecondary),
                          Text(' $deliveries', style: AppTextStyles.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                itemBuilder: (context) => [
                  if (status == 'Pending')
                    PopupMenuItem(
                      onTap: () => controller.verifyAgent(agent['_id'], true),
                      child: const Text('Approve Agent'),
                    ),
                  PopupMenuItem(
                    onTap: () => controller.verifyAgent(agent['_id'], false),
                    child: const Text('Suspend Agent', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
