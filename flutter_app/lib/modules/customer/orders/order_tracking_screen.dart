import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  // Mock data — in production read from Get.arguments and API
  final String _orderId = '#GB2024001';

  final List<_TrackingStep> _steps = [
    _TrackingStep(
      label: 'Order Placed',
      description: 'Your order has been received',
      time: '2:30 PM',
      status: _StepStatus.done,
      icon: Icons.receipt_long_rounded,
    ),
    _TrackingStep(
      label: 'Confirmed',
      description: 'Merchant confirmed the order',
      time: '2:35 PM',
      status: _StepStatus.done,
      icon: Icons.check_circle_outline_rounded,
    ),
    _TrackingStep(
      label: 'Preparing',
      description: 'Your items are being packed',
      time: '2:40 PM',
      status: _StepStatus.active,
      icon: Icons.inventory_2_outlined,
    ),
    _TrackingStep(
      label: 'Out for Delivery',
      description: 'Agent is on the way',
      time: '—',
      status: _StepStatus.pending,
      icon: Icons.delivery_dining_rounded,
    ),
    _TrackingStep(
      label: 'Delivered',
      description: 'Enjoy your order!',
      time: '—',
      status: _StepStatus.pending,
      icon: Icons.home_rounded,
    ),
  ];

  final List<_OrderItem> _items = [
    _OrderItem(name: 'Organic Spinach', qty: 2, unit: '250g', price: 60),
    _OrderItem(name: 'Fresh Tomatoes', qty: 1, unit: '500g', price: 35),
    _OrderItem(name: 'Alphonso Mangoes', qty: 3, unit: 'pc', price: 120),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Track Order $_orderId',
            style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estimated arrival chip
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _pulseCtrl,
                      child: const Icon(Icons.access_time_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Text(
                      'Arriving in 25 mins',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stepper
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: List.generate(_steps.length, (i) {
                  final step = _steps[i];
                  final isLast = i == _steps.length - 1;
                  return _buildStep(step, isLast, i);
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Delivery agent card
            const Text('Delivery Agent',
                style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  // Agent photo placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ravi Kumar',
                            style: AppTextStyles.titleMedium),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.secondary, size: 14),
                            SizedBox(width: 2),
                            Text('4.8 · 312 deliveries',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Phone
                  _AgentIconButton(
                    icon: Icons.call_rounded,
                    onTap: () {
                      // TODO: Launch phone dialer
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Chat
                  _AgentIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      // TODO: Open chat
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Map placeholder
            const Text('Live Location', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAE6),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid lines for map feel
                  CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _MapGridPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: AppColors.primary.withOpacity(0.7),
                          size: 40),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Live tracking coming soon',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Order items summary
            const Text('Order Items', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.eco_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: AppTextStyles.titleMedium),
                            Text('${item.qty} × ${item.unit}',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      Text(
                        '₹${(item.qty * item.price).toStringAsFixed(0)}',
                        style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(_TrackingStep step, bool isLast, int index) {
    final isDone = step.status == _StepStatus.done;
    final isActive = step.status == _StepStatus.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            // Dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary
                    : isActive
                        ? AppColors.primaryContainer
                        : AppColors.border.withOpacity(0.3),
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : isActive
                      ? FadeTransition(
                          opacity: _pulseCtrl,
                          child: Icon(step.icon,
                              color: AppColors.primary, size: 14),
                        )
                      : Icon(step.icon,
                          color: AppColors.textHint, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),

        // Step info
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.md,
                top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDone || isActive
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                Text(
                  step.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDone || isActive
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                if (step.time != '—')
                  Text(step.time,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _StepStatus { done, active, pending }

class _TrackingStep {
  final String label;
  final String description;
  final String time;
  final _StepStatus status;
  final IconData icon;
  const _TrackingStep({
    required this.label,
    required this.description,
    required this.time,
    required this.status,
    required this.icon,
  });
}

class _OrderItem {
  final String name;
  final int qty;
  final String unit;
  final double price;
  const _OrderItem(
      {required this.name,
      required this.qty,
      required this.unit,
      required this.price});
}

class _AgentIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AgentIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
