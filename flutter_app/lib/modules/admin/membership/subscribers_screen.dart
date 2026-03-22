import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/users/user_detail_screen.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock subscribers — replace with API call
  final _subscribers = [
    {
      'name': 'Priya Sharma',
      'email': 'priya@email.com',
      'plan': 'Gold',
      'joinedDate': '15 Jan 2024',
      'renewalDate': '15 Apr 2024',
      'status': 'Active',
      'tab': 0,
    },
    {
      'name': 'Amit Kumar',
      'email': 'amit@email.com',
      'plan': 'Silver',
      'joinedDate': '20 Feb 2024',
      'renewalDate': '20 May 2024',
      'status': 'Active',
      'tab': 0,
    },
    {
      'name': 'Neha Reddy',
      'email': 'neha@email.com',
      'plan': 'Platinum',
      'joinedDate': '01 Mar 2024',
      'renewalDate': '01 Apr 2024',
      'status': 'Active',
      'tab': 0,
    },
    {
      'name': 'Suresh Patel',
      'email': 'suresh@email.com',
      'plan': 'Silver',
      'joinedDate': '10 Jan 2024',
      'renewalDate': '10 Jan 2025',
      'status': 'Active',
      'tab': 0,
    },
    {
      'name': 'Meera Nair',
      'email': 'meera@email.com',
      'plan': 'Gold',
      'joinedDate': '05 Dec 2023',
      'renewalDate': '05 Mar 2024',
      'status': 'Expired',
      'tab': 0,
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

  Color _planColor(String plan) {
    switch (plan) {
      case 'Silver':
        return const Color(0xFF9E9E9E);
      case 'Gold':
        return AppColors.secondary;
      case 'Platinum':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusColor(String status) {
    return status == 'Active' ? AppColors.success : AppColors.error;
  }

  List<Map<String, dynamic>> _subscribersForTab(int tab) {
    if (tab == 0) return _subscribers.cast<Map<String, dynamic>>();
    final planMap = {1: 'Silver', 2: 'Gold', 3: 'Platinum'};
    return _subscribers.where((s) => s['plan'] == planMap[tab]).toList().cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscribers'),
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
            Tab(text: 'Silver'),
            Tab(text: 'Gold'),
            Tab(text: 'Platinum'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStats(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2, 3].map((tab) {
                final list = _subscribersForTab(tab);
                return list.isEmpty
                    ? const Center(child: Text('No subscribers in this plan.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _buildSubscriberCard(list[i]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final total = _subscribers.length;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _stat('Total Subscribers', '$total', AppColors.primary),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Monthly Revenue', '₹3,41,870', AppColors.success),
          Container(width: 1, height: 40, color: AppColors.border),
          _stat('Avg. Lifetime', '8.2 mo', AppColors.info),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSubscriberCard(Map<String, dynamic> sub) {
    final plan = sub['plan'] as String;
    final status = sub['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => Get.to(() => const UserDetailScreen()),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _planColor(plan).withOpacity(0.1),
                child: Text(
                  (sub['name'] as String).substring(0, 2).toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(color: _planColor(plan)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub['name'] as String, style: AppTextStyles.titleMedium),
                    Text(sub['email'] as String, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text('Renews ${sub['renewalDate']}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _planColor(plan).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      plan,
                      style: AppTextStyles.labelSmall.copyWith(color: _planColor(plan)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ],
          ),
        ),
      ),
    );
  }
}
