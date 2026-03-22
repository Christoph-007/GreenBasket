import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AgentTrackScreen extends StatelessWidget {
  const AgentTrackScreen({super.key});

  // Mock tracking data — replace with real-time API / WebSocket
  static const _agent = {
    'name': 'Ravi Kumar',
    'currentOrder': 'GB2024091',
    'eta': '12 min',
    'lastUpdate': '2 min ago',
    'pickup': 'Fresh Farms Organics, MG Road',
    'delivery': '42 MG Road, Koramangala, Bangalore',
    'phone': '+91 76543 21098',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Live Tracking — ${_agent['name']}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('Online', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE8ECEF),
            child: CustomPaint(
              painter: _MapPlaceholderPainter(),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: Color(0xFFBBCCDD)),
                    SizedBox(height: AppSpacing.md),
                    // TODO: Replace with google_maps_flutter or mapbox widget
                    Text('Live Map View', style: TextStyle(color: Color(0xFF99AABB), fontSize: 16)),
                    Text('Integrate with Maps SDK', style: TextStyle(color: Color(0xFF99AABB), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          // Agent info overlay
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: _buildAgentInfoCard(),
          ),
          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentInfoCard() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                _agent['name']!.substring(0, 2).toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_agent['name']!, style: AppTextStyles.titleMedium),
                  Text('Order #${_agent['currentOrder']}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ETA ${_agent['eta']}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                Text('Updated ${_agent['lastUpdate']}', style: AppTextStyles.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Current Order Route', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _routeStep(Icons.store_outlined, 'Pickup', _agent['pickup']!, AppColors.secondary),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Container(width: 2, height: 20, color: AppColors.border),
          ),
          _routeStep(Icons.location_on_outlined, 'Delivery', _agent['delivery']!, AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Launch phone app
                  },
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Call Agent'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open chat or send push notification
                  },
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _routeStep(IconData icon, String type, String address, Color color) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.labelSmall.copyWith(color: color)),
              Text(address, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4DCE4)
      ..strokeWidth = 1;

    // Draw grid to simulate map tiles
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw a mock route line
    final routePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.3)
      ..cubicTo(
        size.width * 0.4, size.height * 0.4,
        size.width * 0.5, size.height * 0.45,
        size.width * 0.6, size.height * 0.55,
      );
    canvas.drawPath(path, routePaint);

    // Draw agent dot
    final agentPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 10, agentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.45), 18,
        Paint()..color = AppColors.primary.withAlpha(80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
