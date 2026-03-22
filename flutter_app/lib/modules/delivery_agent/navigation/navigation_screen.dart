import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';

// TODO: Integrate google_maps_flutter or mapbox_maps for real navigation

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Mock delivery destination — replace with data passed via constructor/controller
  final String _customerName = 'Ananya S.';
  final String _deliveryAddress = '14B, Koramangala 5th Block, Bengaluru 560095';
  final String _eta = '~12 mins';
  final String _distance = '3.2 km';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Navigate to Customer'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              // TODO: Launch phone dialer for customer
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMapView()),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map placeholder background
        Container(
          width: double.infinity,
          color: const Color(0xFFE8EEF2),
          child: CustomPaint(
            painter: _NavigationMapPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        // Compass + zoom controls overlay
        Positioned(
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: Column(
            children: [
              _mapControl(Icons.explore_outlined, () {}),
              const SizedBox(height: AppSpacing.sm),
              _mapControl(Icons.add, () {}),
              const SizedBox(height: AppSpacing.xs),
              _mapControl(Icons.remove, () {}),
            ],
          ),
        ),
        // ETA chip overlay
        Positioned(
          left: AppSpacing.md,
          top: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _eta,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '· $_distance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Center destination pin
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 48),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Customer info
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_customerName, style: AppTextStyles.titleMedium),
                    Text(
                      _deliveryAddress,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _eta,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Launch Google Maps with coordinates
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open in Maps'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as arrived — call API PATCH /agent/jobs/:id/arrived
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Mark as Arrived'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _NavigationMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFCDD5DB)
      ..strokeWidth = 1;

    // Grid
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.65, 0),
        Offset(size.width * 0.65, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7),
        roadPaint);

    // Route highlight
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.85)
      ..lineTo(size.width * 0.2, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.45);

    canvas.drawPath(routePath, routePaint);

    // Agent position dot
    final agentPaint = Paint()..color = AppColors.info;
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.85), 10, agentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.85),
        6,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
