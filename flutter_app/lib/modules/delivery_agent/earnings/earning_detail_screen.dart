import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';

// TODO: Replace mock data with API: GET /agent/earnings/detail?month=2024-03

class EarningDetailScreen extends StatefulWidget {
  const EarningDetailScreen({super.key});

  @override
  State<EarningDetailScreen> createState() => _EarningDetailScreenState();
}

class _EarningDetailScreenState extends State<EarningDetailScreen> {
  final Set<int> _expandedDays = {};

  // Mock daily earnings data — replace with API response
  final List<Map<String, dynamic>> _dailyEarnings = [
    {
      'date': 'Mar 22, 2026',
      'deliveries': 3,
      'amount': 485.0,
      'breakdown': [
        {'id': 'GB2024087', 'amount': 65.0, 'time': '2:30 PM'},
        {'id': 'GB2024086', 'amount': 48.0, 'time': '12:15 PM'},
        {'id': 'GB2024085', 'amount': 372.0, 'time': '10:00 AM'},
      ],
    },
    {
      'date': 'Mar 21, 2026',
      'deliveries': 5,
      'amount': 920.0,
      'breakdown': [
        {'id': 'GB2024081', 'amount': 72.0, 'time': '7:00 PM'},
        {'id': 'GB2024080', 'amount': 85.0, 'time': '5:30 PM'},
        {'id': 'GB2024079', 'amount': 55.0, 'time': '3:45 PM'},
        {'id': 'GB2024078', 'amount': 620.0, 'time': '1:00 PM'},
        {'id': 'GB2024077', 'amount': 88.0, 'time': '11:20 AM'},
      ],
    },
    {
      'date': 'Mar 20, 2026',
      'deliveries': 4,
      'amount': 740.0,
      'breakdown': [
        {'id': 'GB2024073', 'amount': 55.0, 'time': '6:15 PM'},
        {'id': 'GB2024072', 'amount': 490.0, 'time': '4:00 PM'},
        {'id': 'GB2024071', 'amount': 92.0, 'time': '2:30 PM'},
        {'id': 'GB2024070', 'amount': 103.0, 'time': '10:45 AM'},
      ],
    },
    {
      'date': 'Mar 19, 2026',
      'deliveries': 6,
      'amount': 1240.0,
      'breakdown': [
        {'id': 'GB2024065', 'amount': 78.0, 'time': '8:00 PM'},
        {'id': 'GB2024064', 'amount': 130.0, 'time': '6:30 PM'},
        {'id': 'GB2024063', 'amount': 55.0, 'time': '5:00 PM'},
        {'id': 'GB2024062', 'amount': 800.0, 'time': '3:15 PM'},
        {'id': 'GB2024061', 'amount': 95.0, 'time': '1:45 PM'},
        {'id': 'GB2024060', 'amount': 82.0, 'time': '11:00 AM'},
      ],
    },
    {
      'date': 'Mar 18, 2026',
      'deliveries': 3,
      'amount': 480.0,
      'breakdown': [
        {'id': 'GB2024055', 'amount': 60.0, 'time': '7:30 PM'},
        {'id': 'GB2024054', 'amount': 360.0, 'time': '4:00 PM'},
        {'id': 'GB2024053', 'amount': 60.0, 'time': '11:30 AM'},
      ],
    },
  ];

  double get _totalEarnings =>
      _dailyEarnings.fold(0, (sum, d) => sum + d['amount']);
  int get _totalDeliveries =>
      _dailyEarnings.fold(0, (sum, d) => sum + (d['deliveries'] as int));
  int get _workingDays => _dailyEarnings.length;
  double get _avgPerDay => _totalEarnings / _workingDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings Detail — March 2026'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildDailyList(),
                ],
              ),
            ),
          ),
          _buildDownloadButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            'March 2026 Summary',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '₹${_totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _summaryItem('$_totalDeliveries', 'Deliveries'),
              _divider(),
              _summaryItem('$_workingDays', 'Working Days'),
              _divider(),
              _summaryItem(
                  '₹${_avgPerDay.toStringAsFixed(0)}', 'Avg / Day'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildDailyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Breakdown', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(_dailyEarnings.length, (index) {
          return _buildDayCard(index, _dailyEarnings[index]);
        }),
      ],
    );
  }

  Widget _buildDayCard(int index, Map<String, dynamic> day) {
    final isExpanded = _expandedDays.contains(index);
    final deliveries = day['breakdown'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
        children: [
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedDays.remove(index);
              } else {
                _expandedDays.add(index);
              }
            }),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.calendar_today,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day['date'], style: AppTextStyles.titleMedium),
                      Text(
                        '${day['deliveries']} deliveries',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '₹${(day['amount'] as double).toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: deliveries.map((d) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.delivery_dining_outlined,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Order #${d['id']}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          d['time'],
                          style: AppTextStyles.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          '₹${(d['amount'] as double).toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Generate and download PDF statement via API
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download Statement'),
        ),
      ),
    );
  }
}
