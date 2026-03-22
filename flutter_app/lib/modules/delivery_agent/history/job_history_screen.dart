import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'job_detail_screen.dart';

// TODO: Replace mock data with API call to GET /agent/deliveries?filter=today|week|month|all

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Today', 'This Week', 'This Month', 'All'];

  // Mock delivery history data
  final List<Map<String, dynamic>> _deliveries = [
    {
      'id': 'GB2024087',
      'customerName': 'Raj***',
      'pickupArea': 'HSR Layout',
      'deliveryArea': 'Koramangala',
      'distance': '3.2 km',
      'earnings': '₹65.00',
      'timeTaken': '18 mins',
      'date': 'Today, 2:30 PM',
      'status': 'Delivered',
    },
    {
      'id': 'GB2024086',
      'customerName': 'Priy***',
      'pickupArea': 'Indiranagar',
      'deliveryArea': 'Domlur',
      'distance': '2.1 km',
      'earnings': '₹48.00',
      'timeTaken': '14 mins',
      'date': 'Today, 12:15 PM',
      'status': 'Delivered',
    },
    {
      'id': 'GB2024085',
      'customerName': 'Aman***',
      'pickupArea': 'BTM Layout',
      'deliveryArea': 'Jayanagar',
      'distance': '4.5 km',
      'earnings': '₹78.00',
      'timeTaken': '25 mins',
      'date': 'Today, 10:00 AM',
      'status': 'Delivered',
    },
    {
      'id': 'GB2024081',
      'customerName': 'Neh***',
      'pickupArea': 'Whitefield',
      'deliveryArea': 'Marathahalli',
      'distance': '3.8 km',
      'earnings': '₹72.00',
      'timeTaken': '22 mins',
      'date': 'Yesterday, 6:45 PM',
      'status': 'Delivered',
    },
    {
      'id': 'GB2024078',
      'customerName': 'Sar***',
      'pickupArea': 'JP Nagar',
      'deliveryArea': 'Banashankari',
      'distance': '2.7 km',
      'earnings': '₹55.00',
      'timeTaken': '16 mins',
      'date': 'Yesterday, 3:20 PM',
      'status': 'Delivered',
    },
  ];

  List<Map<String, dynamic>> get _filteredDeliveries {
    // In production, filter based on API response with date range
    if (_selectedFilter == 0) return _deliveries.take(3).toList();
    if (_selectedFilter == 1) return _deliveries;
    return _deliveries;
  }

  String get _totalEarnings {
    final total = _filteredDeliveries.fold<double>(
      0,
      (sum, d) => sum + double.parse(d['earnings'].replaceAll('₹', '')),
    );
    return '₹${total.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          _buildFilterChips(),
          Expanded(
            child: _filteredDeliveries.isEmpty
                ? _buildEmptyState()
                : _buildDeliveryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          _summaryItem(
            '${_filteredDeliveries.length}',
            'Deliveries',
            Icons.delivery_dining_outlined,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _summaryItem(
            _totalEarnings,
            'Total Earned',
            Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = index),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredDeliveries.length,
      itemBuilder: (context, index) {
        return _buildDeliveryCard(_filteredDeliveries[index]);
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobDetailScreen(deliveryId: delivery['id']),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery['id']}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    delivery['status'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(delivery['customerName'], style: AppTextStyles.bodySmall),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.route_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(delivery['distance'], style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.store_outlined,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    delivery['pickupArea'],
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    delivery['deliveryArea'],
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(delivery['timeTaken'], style: AppTextStyles.bodySmall),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(delivery['date'], style: AppTextStyles.bodySmall),
                  ],
                ),
                Text(
                  delivery['earnings'],
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          const Text('No deliveries yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Completed deliveries will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
