import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class DeliveryZonesScreen extends StatefulWidget {
  const DeliveryZonesScreen({super.key});

  @override
  State<DeliveryZonesScreen> createState() => _DeliveryZonesScreenState();
}

class _DeliveryZonesScreenState extends State<DeliveryZonesScreen> {
  // Mock zones — TODO: fetch from API
  final List<Map<String, dynamic>> _zones = [
    {
      'name': 'Central Zone',
      'radius': 3.0,
      'charge': 30.0,
      'minOrder': 150.0,
      'active': true,
    },
    {
      'name': 'East Zone',
      'radius': 5.0,
      'charge': 45.0,
      'minOrder': 200.0,
      'active': true,
    },
    {
      'name': 'West Zone',
      'radius': 8.0,
      'charge': 60.0,
      'minOrder': 300.0,
      'active': false,
    },
    {
      'name': 'Suburbs',
      'radius': 15.0,
      'charge': 80.0,
      'minOrder': 500.0,
      'active': true,
    },
  ];

  void _deleteZone(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Zone', style: AppTextStyles.titleLarge),
        content: Text(
            'Delete "${_zones[index]['name']}"? Customers in this zone won\'t be able to order.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _zones.removeAt(index));
              Navigator.pop(ctx);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Zones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map placeholder
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E8),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  // Grid lines to simulate map
                  CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: _MapGridPainter(),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8)
                            ],
                          ),
                          child: const Icon(Icons.location_on,
                              color: AppColors.primary, size: 36),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color:
                                AppColors.surface.withOpacity(0.9),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'Zone map coming soon',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Zone count indicator
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${_zones.where((z) => z['active'] as bool).length} active zones',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Zones', style: AppTextStyles.titleLarge),
                Text('${_zones.length} zones',
                    style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            ..._zones.asMap().entries.map((e) =>
                _buildZoneCard(e.value, e.key)),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/merchant/zones/edit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label:
            Text('Add Zone', style: AppTextStyles.labelLarge),
      ),
    );
  }

  Widget _buildZoneCard(Map<String, dynamic> zone, int index) {
    final isActive = zone['active'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryContainer
                        : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.radio_button_checked,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone['name'] as String,
                          style: AppTextStyles.titleMedium),
                      Text(
                        '${zone['radius']} km radius',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (v) =>
                      setState(() => _zones[index]['active'] = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _zoneInfoItem(
                    Icons.delivery_dining_outlined,
                    'Delivery',
                    '₹${(zone['charge'] as double).toStringAsFixed(0)}',
                  ),
                ),
                Container(
                    width: 1,
                    height: 32,
                    color: AppColors.border),
                Expanded(
                  child: _zoneInfoItem(
                    Icons.shopping_bag_outlined,
                    'Min Order',
                    '₹${(zone['minOrder'] as double).toStringAsFixed(0)}',
                  ),
                ),
                Container(
                    width: 1,
                    height: 32,
                    color: AppColors.border),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => Get.toNamed(
                            '/merchant/zones/edit',
                            arguments: zone),
                        icon: const Icon(Icons.edit_outlined,
                            size: 20,
                            color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        onPressed: () => _deleteZone(index),
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.06)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}
