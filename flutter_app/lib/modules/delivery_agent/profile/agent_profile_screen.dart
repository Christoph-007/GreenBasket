import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/auth/auth_controller.dart';
import 'edit_agent_profile_screen.dart';
import 'agent_documents_screen.dart';
import '../settings/agent_settings_screen.dart';

// TODO: Replace mock data with AgentController + API call GET /agent/profile

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  // Mock agent profile data
  static const _profile = {
    'name': 'Ravi Kumar',
    'phone': '+91 98765 43210',
    'rating': 4.8,
    'vehicleType': '2-Wheeler',
    'totalDeliveries': 1247,
    'memberSince': 'Jan 2024',
    'thisMonthEarnings': '₹8,750',
    'isAvailable': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: AppSpacing.md),
              _buildStatsRow(),
              const SizedBox(height: AppSpacing.md),
              _buildMenuList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Stack(
        children: [
          // Availability badge top right
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _profile['isAvailable'] as bool
                    ? AppColors.success
                    : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _profile['isAvailable'] as bool ? 'Available' : 'Offline',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile content
          Column(
            children: [
              // Photo
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: AppColors.primary),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _profile['name'] as String,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Rating stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (i) {
                    final rating = _profile['rating'] as double;
                    return Icon(
                      i < rating.floor()
                          ? Icons.star
                          : (i < rating ? Icons.star_half : Icons.star_border),
                      color: AppColors.secondary,
                      size: 18,
                    );
                  }),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_profile['rating']}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Vehicle badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.two_wheeler, color: Colors.white, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _profile['vehicleType'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
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
        child: Row(
          children: [
            _statItem('${_profile['totalDeliveries']}', 'Total Trips'),
            _statDivider(),
            _statItem(_profile['memberSince'] as String, 'Member Since'),
            _statDivider(),
            _statItem(_profile['thisMonthEarnings'] as String, 'This Month'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.edit_outlined,
        title: 'Edit Profile',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditAgentProfileScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.badge_outlined,
        title: 'My Documents',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AgentDocumentsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.two_wheeler_outlined,
        title: 'Vehicle Info',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditAgentProfileScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AgentSettingsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout,
        title: 'Logout',
        isDestructive: true,
        onTap: () {
          // TODO: Call AgentController logout
          Get.find<AuthController>().logout();
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
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
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    item.icon,
                    color: item.isDestructive
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                  title: Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: item.isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: item.isDestructive
                      ? null
                      : const Icon(Icons.chevron_right,
                          color: AppColors.textHint),
                  onTap: item.onTap,
                ),
                if (index < items.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
