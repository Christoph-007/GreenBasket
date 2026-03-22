import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: GBAppBar(title: 'Notifications'),
      body: EmptyState(
        icon: Icons.notifications_none_outlined,
        title: 'No notifications',
        message: 'You\'re all caught up!',
      ),
    );
  }
}
