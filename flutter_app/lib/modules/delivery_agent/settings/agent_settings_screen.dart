import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/auth/auth_controller.dart';

// TODO: Persist settings via SharedPreferences or PATCH /agent/settings API

class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  // Notification settings
  bool _newOrderAlerts = true;
  bool _earningsUpdates = true;
  bool _promotions = false;

  // Delivery settings
  bool _autoAccept = false;
  double _maxDistance = 8.0; // km

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildToggleTile(
                  'New Order Alerts',
                  'Get notified for new delivery requests',
                  Icons.delivery_dining_outlined,
                  _newOrderAlerts,
                  (val) => setState(() => _newOrderAlerts = val),
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  'Earnings Updates',
                  'Daily and weekly earnings summaries',
                  Icons.account_balance_wallet_outlined,
                  _earningsUpdates,
                  (val) => setState(() => _earningsUpdates = val),
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  'Promotions',
                  'Bonus offers and incentive alerts',
                  Icons.local_offer_outlined,
                  _promotions,
                  (val) => setState(() => _promotions = val),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSection(
              title: 'Delivery Preferences',
              icon: Icons.tune_outlined,
              children: [
                _buildToggleTile(
                  'Auto-Accept Orders',
                  'Automatically accept nearby orders',
                  Icons.check_circle_outline,
                  _autoAccept,
                  (val) => setState(() => _autoAccept = val),
                ),
                const Divider(height: 1),
                _buildSliderTile(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSection(
              title: 'Account',
              icon: Icons.manage_accounts_outlined,
              children: [
                _buildActionTile(
                  'Change Password',
                  Icons.lock_outline,
                  () {
                    // TODO: Navigate to change password screen
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  'Help & Support',
                  Icons.help_outline,
                  () {
                    // TODO: Navigate to support screen / launch URL
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDangerZone(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max Delivery Distance',
                        style: AppTextStyles.bodyLarge),
                    Text('Orders beyond this distance are hidden',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                '${_maxDistance.toInt()} km',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: _maxDistance,
              min: 1,
              max: 15,
              divisions: 14,
              onChanged: (val) => setState(() => _maxDistance = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km', style: AppTextStyles.labelSmall),
              Text('15 km', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: AppColors.error, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Danger Zone',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog();
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                _showDeleteAccountDialog();
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: AppTextStyles.titleLarge),
        content: const Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call AgentController.logout()
              Get.find<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: AppTextStyles.titleLarge),
        content: const Text(
          'This action cannot be undone. All your data including earnings history will be permanently deleted.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call DELETE /agent/account API
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
