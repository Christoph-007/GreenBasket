import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class _Dispute {
  final String id;
  final String orderId;
  final String issueType;
  final String status;
  final String date;
  final String description;
  final bool isActive;

  const _Dispute({
    required this.id,
    required this.orderId,
    required this.issueType,
    required this.status,
    required this.date,
    required this.description,
    required this.isActive,
  });
}

const List<_Dispute> _mockDisputes = [
  _Dispute(
    id: 'd1',
    orderId: '#GB2024001',
    issueType: 'Wrong Item',
    status: 'Under Review',
    date: '20 Mar 2026',
    description:
        'Received Kale instead of Spinach in my order. Quantity also seemed less.',
    isActive: true,
  ),
  _Dispute(
    id: 'd2',
    orderId: '#GB2024008',
    issueType: 'Quality Issue',
    status: 'Resolved',
    date: '10 Mar 2026',
    description: 'Tomatoes were over-ripe and not fresh at all.',
    isActive: false,
  ),
  _Dispute(
    id: 'd3',
    orderId: '#GB2024015',
    issueType: 'Missing Item',
    status: 'Pending',
    date: '15 Mar 2026',
    description: 'Coriander leaves were missing from the order bag.',
    isActive: true,
  ),
];

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // Dialog state
  String _dialogIssueType = 'Wrong Item';
  final _dialogDescCtrl = TextEditingController();
  final _dialogOrderCtrl = TextEditingController();

  final List<String> _issueTypes = [
    'Wrong Item',
    'Missing Item',
    'Quality Issue',
    'Damaged Package',
    'Overcharged',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _dialogDescCtrl.dispose();
    _dialogOrderCtrl.dispose();
    super.dispose();
  }

  void _showRaiseDisputeDialog() {
    _dialogIssueType = _issueTypes.first;
    _dialogDescCtrl.clear();
    _dialogOrderCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          title: const Text('Raise a Dispute',
              style: AppTextStyles.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _dialogOrderCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Order ID',
                    prefixIcon: Icon(Icons.receipt_long_outlined,
                        size: 20),
                    hintText: '#GB2024001',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Issue Type',
                    style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.border),
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dialogIssueType,
                      isExpanded: true,
                      onChanged: (v) =>
                          setDlgState(() => _dialogIssueType = v!),
                      items: _issueTypes
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t,
                                    style: AppTextStyles.bodyMedium),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _dialogDescCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    hintText: 'Describe the issue in detail...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Dispute Raised',
                  'Our team will review it within 24 hours',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDisputes =
        _mockDisputes.where((d) => d.isActive).toList();
    final resolvedDisputes =
        _mockDisputes.where((d) => !d.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Disputes',
            style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showRaiseDisputeDialog,
            tooltip: 'Raise a Dispute',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelLarge,
          tabs: [
            Tab(text: 'Active (${activeDisputes.length})'),
            Tab(text: 'Resolved (${resolvedDisputes.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Active
          _buildList(activeDisputes),
          // Resolved
          _buildList(resolvedDisputes),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRaiseDisputeDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.report_problem_rounded),
        label: const Text(
          'Raise a Dispute',
          style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildList(List<_Dispute> disputes) {
    if (disputes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: AppSpacing.md),
            const Text('No disputes here',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('All disputes have been resolved',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: disputes.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _buildDisputeCard(disputes[i]),
    );
  }

  Widget _buildDisputeCard(_Dispute dispute) {
    Color statusColor;
    switch (dispute.status) {
      case 'Resolved':
        statusColor = AppColors.success;
        break;
      case 'Under Review':
        statusColor = AppColors.primary;
        break;
      default:
        statusColor = AppColors.warning;
    }

    Color issueColor;
    switch (dispute.issueType) {
      case 'Wrong Item':
        issueColor = AppColors.error;
        break;
      case 'Missing Item':
        issueColor = AppColors.warning;
        break;
      case 'Quality Issue':
        issueColor = AppColors.secondary;
        break;
      default:
        issueColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dispute.orderId,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary)),
              const Spacer(),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  dispute.status,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              // Issue type badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: issueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  dispute.issueType,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: issueColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(dispute.date, style: AppTextStyles.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dispute.description,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
