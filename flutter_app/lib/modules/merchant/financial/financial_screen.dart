import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 2; // Default: This Month

  // Mock data per period — TODO: fetch from API
  final List<Map<String, dynamic>> _periodData = [
    {
      'label': 'Today',
      'grossSales': 3450.0,
      'netEarnings': 3105.0,
      'commission': 345.0,
      'pendingPayout': 3105.0,
      'chartValues': [0.2, 0.5, 0.3, 0.7, 0.9, 0.6, 0.8, 0.4, 1.0, 0.7],
    },
    {
      'label': 'This Week',
      'grossSales': 24800.0,
      'netEarnings': 22320.0,
      'commission': 2480.0,
      'pendingPayout': 12450.0,
      'chartValues': [0.3, 0.5, 0.4, 0.8, 0.6, 0.9, 1.0],
    },
    {
      'label': 'This Month',
      'grossSales': 98500.0,
      'netEarnings': 88650.0,
      'commission': 9850.0,
      'pendingPayout': 12450.0,
      'chartValues': [0.4, 0.5, 0.3, 0.6, 0.5, 0.7, 0.8, 0.6, 0.9, 0.8, 1.0, 0.7],
    },
    {
      'label': 'All Time',
      'grossSales': 542000.0,
      'netEarnings': 487800.0,
      'commission': 54200.0,
      'pendingPayout': 12450.0,
      'chartValues': [0.2, 0.3, 0.4, 0.5, 0.6, 0.5, 0.7, 0.8, 0.9, 0.8, 1.0, 0.9],
    },
  ];

  // Mock transactions — TODO: fetch from API
  final List<Map<String, dynamic>> _transactions = [
    {
      'orderId': 'GB2024001',
      'date': 'Mar 22, 10:30 AM',
      'amount': 520.0,
      'commission': 52.0,
      'net': 468.0,
    },
    {
      'orderId': 'GB2024002',
      'date': 'Mar 22, 09:15 AM',
      'amount': 340.0,
      'commission': 34.0,
      'net': 306.0,
    },
    {
      'orderId': 'GB2024003',
      'date': 'Mar 21, 06:45 PM',
      'amount': 780.0,
      'commission': 78.0,
      'net': 702.0,
    },
    {
      'orderId': 'GB2024004',
      'date': 'Mar 21, 03:20 PM',
      'amount': 210.0,
      'commission': 21.0,
      'net': 189.0,
    },
    {
      'orderId': 'GB2024005',
      'date': 'Mar 20, 11:10 AM',
      'amount': 450.0,
      'commission': 45.0,
      'net': 405.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: _selectedPeriod);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedPeriod = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _periodData[_selectedPeriod];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // TODO: download report
              Get.snackbar('Downloading', 'Report is being generated...',
                  snackPosition: SnackPosition.BOTTOM);
            },
            tooltip: 'Download Report',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.labelSmall,
          unselectedLabelStyle: AppTextStyles.labelSmall,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          isScrollable: false,
          tabs: _periodData.map((p) => Tab(text: p['label'] as String)).toList(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
              children: [
                _statCard(
                  'Gross Sales',
                  _formatAmount(data['grossSales'] as double),
                  Icons.trending_up_rounded,
                  AppColors.primary,
                ),
                _statCard(
                  'Net Earnings',
                  _formatAmount(data['netEarnings'] as double),
                  Icons.account_balance_wallet_outlined,
                  AppColors.success,
                ),
                _statCard(
                  'Platform Fee',
                  _formatAmount(data['commission'] as double),
                  Icons.percent_rounded,
                  AppColors.secondary,
                ),
                _statCard(
                  'Pending Payout',
                  _formatAmount(data['pendingPayout'] as double),
                  Icons.schedule_outlined,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Chart
            Text('Earnings Trend', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _buildLineChart(data['chartValues'] as List<double>),
            const SizedBox(height: AppSpacing.lg),

            // Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: AppTextStyles.titleLarge),
                TextButton(
                  onPressed: () {
                    // TODO: navigate to full transactions list
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTransactionHeader(),
            ..._transactions.map(_buildTransactionRow),
            const SizedBox(height: AppSpacing.md),

            // Download button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: download report
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Download Report'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(value,
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> values) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 120),
        painter: _LineChartPainter(values: values),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.md)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Order ID',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark))),
          Expanded(
              flex: 2,
              child: Text('Date',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark))),
          Expanded(
              child: Text('Amount',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.right)),
          Expanded(
              child: Text('Fee',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.right)),
          Expanded(
              child: Text('Net',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> t) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('#${t['orderId']}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: Text(t['date'] as String,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              child: Text(
                  '₹${(t['amount'] as double).toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.right)),
          Expanded(
              child: Text(
                  '-₹${(t['commission'] as double).toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                  textAlign: TextAlign.right)),
          Expanded(
              child: Text(
                  '₹${(t['net'] as double).toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  const _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final n = values.length;
    final step = size.width / (n - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < n; i++) {
      final x = i * step;
      final y = size.height - (values[i] * size.height * 0.9);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo((n - 1) * step, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots
    for (int i = 0; i < n; i++) {
      final x = i * step;
      final y = size.height - (values[i] * size.height * 0.9);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.values != values;
}
