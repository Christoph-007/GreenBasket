import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'earning_detail_screen.dart';

// TODO: Replace mock data with API: GET /agent/earnings?period=today|week|month

class AgentEarningsScreen extends StatefulWidget {
  const AgentEarningsScreen({super.key});

  @override
  State<AgentEarningsScreen> createState() => _AgentEarningsScreenState();
}

class _AgentEarningsScreenState extends State<AgentEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock earnings data per period
  final Map<String, Map<String, dynamic>> _earningsData = {
    'Today': {
      'total': '₹485.00',
      'deliveries': 3,
      'avgPerDelivery': '₹161.67',
      'bestDay': '—',
      'basePay': 90.0,
      'distanceBonus': 45.0,
      'tips': 60.0,
      'incentives': 290.0,
      'chartHeights': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0], // Only today
    },
    'This Week': {
      'total': '₹1,240.00',
      'deliveries': 18,
      'avgPerDelivery': '₹68.89',
      'bestDay': 'Friday',
      'basePay': 540.0,
      'distanceBonus': 270.0,
      'tips': 230.0,
      'incentives': 200.0,
      'chartHeights': [0.6, 0.75, 0.5, 0.85, 1.0, 0.9, 0.65],
    },
    'This Month': {
      'total': '₹8,750.00',
      'deliveries': 127,
      'avgPerDelivery': '₹68.90',
      'bestDay': 'Mar 15',
      'basePay': 3810.0,
      'distanceBonus': 1905.0,
      'tips': 1635.0,
      'incentives': 1400.0,
      'chartHeights': [0.8, 0.65, 0.9, 0.7, 1.0, 0.75, 0.85],
    },
  };

  String get _currentPeriod =>
      ['Today', 'This Week', 'This Month'][_tabController.index];

  Map<String, dynamic> get _current => _earningsData[_currentPeriod]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Earnings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalDisplay(),
            const SizedBox(height: AppSpacing.md),
            _buildStatsRow(),
            const SizedBox(height: AppSpacing.md),
            _buildBarChart(),
            const SizedBox(height: AppSpacing.md),
            _buildBreakdown(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EarningDetailScreen(),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View Detailed Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            _currentPeriod == 'Today' ? 'Today\'s Earnings' : '$_currentPeriod Earnings',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _current['total'],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_current['deliveries']} deliveries completed',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('Deliveries', '${_current['deliveries']}',
            Icons.delivery_dining_outlined),
        const SizedBox(width: AppSpacing.sm),
        _statCard('Avg / Trip', _current['avgPerDelivery'],
            Icons.trending_up_outlined),
        const SizedBox(width: AppSpacing.sm),
        _statCard('Best Day', _current['bestDay'],
            Icons.emoji_events_outlined),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = _current['chartHeights'] as List<double>;
    const maxBarHeight = 100.0;

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
          const Text('Earnings by Day', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final barHeight = maxBarHeight * heights[i];
              final isToday = i == 6; // Sunday = today in this mock
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    width: 28,
                    height: barHeight.clamp(4, maxBarHeight),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    days[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown() {
    final d = _current;
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
          const Text('Earnings Breakdown', style: AppTextStyles.titleLarge),
          const Divider(height: AppSpacing.lg),
          _breakdownRow(
              'Base Pay', d['basePay'], Icons.payments_outlined,
              AppColors.info),
          const Divider(height: AppSpacing.md),
          _breakdownRow(
              'Distance Bonus', d['distanceBonus'], Icons.route_outlined,
              AppColors.warning),
          const Divider(height: AppSpacing.md),
          _breakdownRow(
              'Tips', d['tips'], Icons.favorite_border,
              AppColors.error),
          const Divider(height: AppSpacing.md),
          _breakdownRow(
              'Incentives', d['incentives'], Icons.emoji_events_outlined,
              AppColors.success),
        ],
      ),
    );
  }

  Widget _breakdownRow(
      String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTextStyles.titleMedium,
        ),
      ],
    );
  }
}
