import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';

// TODO: Fetch delivery detail from API: GET /agent/deliveries/:id

class JobDetailScreen extends StatelessWidget {
  final String deliveryId;

  const JobDetailScreen({super.key, required this.deliveryId});

  // Mock data — replace with API-fetched delivery detail
  Map<String, dynamic> get _delivery => {
        'id': deliveryId,
        'status': 'Delivered',
        'customerName': 'Raj***',
        'customerAddress': '14B, Koramangala 5th Block, Bengaluru 560095',
        'customerRating': 5,
        'merchantName': "Priya's Organic Store",
        'merchantAddress': 'Shop 12, HSR Layout Sector 2, Bengaluru',
        'distance': '3.2 km',
        'timeTaken': '18 mins',
        'timeline': [
          {'event': 'Order Accepted', 'time': '2:12 PM', 'done': true},
          {'event': 'Reached Pickup', 'time': '2:22 PM', 'done': true},
          {'event': 'Picked Up', 'time': '2:25 PM', 'done': true},
          {'event': 'Reached Customer', 'time': '2:43 PM', 'done': true},
          {'event': 'Delivered', 'time': '2:45 PM', 'done': true},
        ],
        'basePay': 30.0,
        'distanceBonus': 15.0,
        'tip': 20.0,
        'total': 65.0,
        'date': 'Today, Mar 22 2026',
      };

  @override
  Widget build(BuildContext context) {
    final d = _delivery;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Delivery #$deliveryId'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(d),
            const SizedBox(height: AppSpacing.md),
            _buildTimeline(d['timeline']),
            const SizedBox(height: AppSpacing.md),
            _buildCustomerInfo(d),
            const SizedBox(height: AppSpacing.md),
            _buildMerchantInfo(d),
            const SizedBox(height: AppSpacing.md),
            _buildEarningsBreakdown(d),
            const SizedBox(height: AppSpacing.md),
            _buildTripStats(d),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> d) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d['status'],
                style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
              ),
              Text(
                d['date'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '₹${d['total'].toStringAsFixed(2)}',
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> events) {
    return _sectionCard(
      title: 'Delivery Timeline',
      child: Column(
        children: List.generate(events.length, (index) {
          final event = events[index];
          final isLast = index == events.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: event['done']
                          ? AppColors.success
                          : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      event['done'] ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: event['done']
                          ? AppColors.success.withOpacity(0.4)
                          : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event['event'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: event['done']
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      Text(
                        event['time'],
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCustomerInfo(Map<String, dynamic> d) {
    return _sectionCard(
      title: 'Customer',
      child: Column(
        children: [
          _infoRow(Icons.person_outline, 'Name', d['customerName']),
          const Divider(height: AppSpacing.lg),
          _infoRow(Icons.location_on_outlined, 'Address', d['customerAddress']),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.star_outlined,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              const Text('Rating Given', style: AppTextStyles.bodyMedium),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < d['customerRating'] ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantInfo(Map<String, dynamic> d) {
    return _sectionCard(
      title: 'Pickup / Merchant',
      child: Column(
        children: [
          _infoRow(Icons.store_outlined, 'Store', d['merchantName']),
          const Divider(height: AppSpacing.lg),
          _infoRow(Icons.location_on_outlined, 'Pickup Address',
              d['merchantAddress']),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(Map<String, dynamic> d) {
    return _sectionCard(
      title: 'Earnings Breakdown',
      child: Column(
        children: [
          _earningsRow('Base Pay', d['basePay']),
          const Divider(height: AppSpacing.md),
          _earningsRow('Distance Bonus', d['distanceBonus']),
          const Divider(height: AppSpacing.md),
          _earningsRow('Tip', d['tip']),
          const Divider(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earned',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${d['total'].toStringAsFixed(2)}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripStats(Map<String, dynamic> d) {
    return Row(
      children: [
        Expanded(
          child: _statChip(Icons.route_outlined, d['distance'], 'Distance'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _statChip(
              Icons.schedule_outlined, d['timeTaken'], 'Time Taken'),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.titleMedium),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _earningsRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
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
          Text(title, style: AppTextStyles.titleLarge),
          const Divider(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
