import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class DisputesAdminScreen extends StatefulWidget {
  const DisputesAdminScreen({super.key});

  @override
  State<DisputesAdminScreen> createState() => _DisputesAdminScreenState();
}

class _DisputesAdminScreenState extends State<DisputesAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final _filters = ['All', 'Damaged Item', 'Wrong Item', 'Not Delivered', 'Quality Issue'];

  // Mock disputes data — replace with API call
  final _disputes = [
    {
      'id': 'DSP001',
      'orderId': 'GB2024082',
      'customer': 'Priya Sharma',
      'merchant': 'Fresh Farms Organics',
      'type': 'Damaged Item',
      'daysOpen': 2,
      'priority': 'High',
      'tab': 0,
    },
    {
      'id': 'DSP002',
      'orderId': 'GB2024075',
      'customer': 'Amit Kumar',
      'merchant': 'Green Grocers',
      'type': 'Wrong Item',
      'daysOpen': 1,
      'priority': 'Medium',
      'tab': 0,
    },
    {
      'id': 'DSP003',
      'orderId': 'GB2024068',
      'customer': 'Neha Reddy',
      'merchant': 'Organic World',
      'type': 'Not Delivered',
      'daysOpen': 3,
      'priority': 'High',
      'tab': 1,
    },
    {
      'id': 'DSP004',
      'orderId': 'GB2024060',
      'customer': 'Suresh Patel',
      'merchant': 'Farm Fresh',
      'type': 'Quality Issue',
      'daysOpen': 5,
      'priority': 'Low',
      'tab': 1,
    },
    {
      'id': 'DSP005',
      'orderId': 'GB2024050',
      'customer': 'Meera Nair',
      'merchant': 'Nature Basket',
      'type': 'Damaged Item',
      'daysOpen': 7,
      'priority': 'Medium',
      'tab': 2,
    },
  ];

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredDisputes(int tab) {
    return _disputes.where((d) {
      final tabMatch = d['tab'] == tab;
      final filterMatch = _selectedFilter == 'All' || d['type'] == _selectedFilter;
      return tabMatch && filterMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Disputes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'Under Review'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSummaryStats(),
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2].map((tab) {
                final disputes = _filteredDisputes(tab);
                return disputes.isEmpty
                    ? const Center(child: Text('No disputes in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: disputes.length,
                        itemBuilder: (_, i) => _buildDisputeCard(disputes[i]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          _statItem('Open', '2', AppColors.error),
          _statDivider(),
          _statItem('Under Review', '2', AppColors.warning),
          _statDivider(),
          _statItem('Resolved', '1', AppColors.success),
        ],
      ),
    );
  }

  Widget _statItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(count, style: AppTextStyles.headlineLarge.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 36, color: AppColors.border);
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final filter = _filters[i];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
          );
        },
      ),
    );
  }

  Widget _buildDisputeCard(Map<String, dynamic> dispute) {
    final priority = dispute['priority'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to dispute detail screen
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#${dispute['id']}', style: AppTextStyles.titleMedium),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _priorityColor(priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      priority,
                      style: AppTextStyles.labelSmall.copyWith(color: _priorityColor(priority)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dispute['daysOpen']}d open',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Order #${dispute['orderId']}', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(dispute['customer'] as String, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dispute['merchant'] as String,
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  dispute['type'] as String,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
