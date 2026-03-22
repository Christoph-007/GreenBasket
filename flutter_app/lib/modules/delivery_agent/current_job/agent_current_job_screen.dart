import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../navigation/navigation_screen.dart';

// TODO: Replace mock data with AgentController + API calls

enum DeliveryStage { reachedPickup, pickedUp, reachedCustomer, delivered }

class AgentCurrentJobScreen extends StatefulWidget {
  const AgentCurrentJobScreen({super.key});

  @override
  State<AgentCurrentJobScreen> createState() => _AgentCurrentJobScreenState();
}

class _AgentCurrentJobScreenState extends State<AgentCurrentJobScreen> {
  bool _isOnline = true;
  DeliveryStage _stage = DeliveryStage.reachedPickup;

  // Mock active job data — replace with API response
  final Map<String, dynamic> _activeJob = {
    'orderId': 'GB2024087',
    'customerName': 'Ananya S.',
    'customerPhone': '+91 98765 43210',
    'pickupAddress': 'Priya\'s Organic Store, HSR Layout, Bengaluru',
    'deliveryAddress': '14B, Koramangala 5th Block, Bengaluru 560095',
    'items': '3 items — Spinach, Tomatoes, Carrots',
    'amount': '₹348.00',
    'distance': '3.2 km',
    'estimatedTime': '18 mins',
  };

  String get _stageLabel {
    switch (_stage) {
      case DeliveryStage.reachedPickup:
        return 'Reached Pickup';
      case DeliveryStage.pickedUp:
        return 'Picked Up';
      case DeliveryStage.reachedCustomer:
        return 'Reached Customer';
      case DeliveryStage.delivered:
        return 'Delivered';
    }
  }

  String get _nextActionLabel {
    switch (_stage) {
      case DeliveryStage.reachedPickup:
        return 'Mark as Picked Up';
      case DeliveryStage.pickedUp:
        return 'Reached Customer';
      case DeliveryStage.reachedCustomer:
        return 'Mark as Delivered';
      case DeliveryStage.delivered:
        return 'Completed';
    }
  }

  void _advanceStage() {
    if (_stage == DeliveryStage.delivered) return;
    setState(() {
      _stage = DeliveryStage.values[_stage.index + 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_isOnline) ...[
                _buildActiveJobCard(),
                _buildMapPlaceholder(),
                _buildActionButtons(),
                _buildTodaySummary(),
              ] else
                _buildOfflineState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Ravi!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isOnline ? 'You are online' : 'You are offline',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: _isOnline,
                onChanged: (val) => setState(() => _isOnline = val),
                activeColor: Colors.white,
                activeTrackColor: AppColors.success,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${_activeJob['orderId']}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  _buildStageBadge(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Customer info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.person, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeJob['customerName'],
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            _activeJob['customerPhone'],
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  // Pickup address
                  _buildAddressRow(
                    Icons.store_outlined,
                    'Pickup',
                    _activeJob['pickupAddress'],
                    AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Route line
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Container(
                      width: 2,
                      height: 16,
                      color: AppColors.border,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Delivery address
                  _buildAddressRow(
                    Icons.location_on_outlined,
                    'Deliver To',
                    _activeJob['deliveryAddress'],
                    AppColors.error,
                  ),
                  const Divider(height: AppSpacing.lg),
                  // Items & amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _activeJob['items'],
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Text(
                        _activeJob['amount'],
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.route_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${_activeJob['distance']} • ${_activeJob['estimatedTime']}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NavigationScreen(),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation_outlined,
                                size: 14, color: AppColors.info),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Navigate',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(
    IconData icon,
    String label,
    String address,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(address, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _stage == DeliveryStage.delivered
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _stageLabel,
        style: AppTextStyles.labelSmall.copyWith(
          color: _stage == DeliveryStage.delivered
              ? AppColors.success
              : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Simulated map grid lines
            CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _MapGridPainter(),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Route: ${_activeJob['distance']} away',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap Navigate to open maps',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Stage advance button
          if (_stage != DeliveryStage.delivered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _advanceStage,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_nextActionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Order Delivered Successfully!',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Call customer button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Launch phone dialer with customer number
              },
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Call Customer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.today_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            const Text("Today's Summary",
                style: AppTextStyles.titleMedium),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹485.00',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '3 deliveries',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new,
              size: 64,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            "You're Offline",
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Go online to start receiving delivery orders.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isOnline = true),
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Go Online'),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDD5DB)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw a simple route line
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.75, size.height * 0.25);

    canvas.drawPath(path, routePaint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
