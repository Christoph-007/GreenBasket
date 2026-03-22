import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedAudience = 'All Users';
  final _audiences = ['All Users', 'Customers Only', 'Merchants Only', 'Agents Only'];

  final List<String> _selectedTypes = ['Push'];
  final _notifTypes = ['Push', 'Email', 'SMS'];

  // Mock recent notifications — replace with API call
  final _recentNotifications = [
    {
      'title': 'Weekend Sale is Live!',
      'body': 'Shop now and get up to 20% off on all orders.',
      'audience': 'All Users',
      'sentAt': 'Today, 9:00 AM',
      'reach': '8,420',
    },
    {
      'title': 'New Feature: Recipe Box',
      'body': 'Explore healthy recipes and order the ingredients directly!',
      'audience': 'Customers Only',
      'sentAt': 'Yesterday, 3:00 PM',
      'reach': '6,240',
    },
    {
      'title': 'Payout Processing Reminder',
      'body': 'Your pending payout will be processed by end of week.',
      'audience': 'Merchants Only',
      'sentAt': '18 Mar 2024',
      'reach': '142',
    },
  ];

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        if (_selectedTypes.length > 1) _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _sendNow() {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      Get.snackbar('Required Fields', 'Please fill in the notification title and body.',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    // TODO: Call API to send notification
    Get.snackbar(
      'Notification Sent',
      '"${_titleController.text}" sent to $_selectedAudience via ${_selectedTypes.join(', ')}.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
    _titleController.clear();
    _bodyController.clear();
    _imageUrlController.clear();
  }

  void _scheduleNotification() {
    if (_titleController.text.isEmpty) {
      Get.snackbar('Required', 'Please fill in the notification title.',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    // TODO: Open date/time picker and schedule via API
    Get.snackbar('Scheduled', 'Notification scheduling coming soon.',
        backgroundColor: AppColors.info, colorText: Colors.white);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAudienceSelector(),
            const SizedBox(height: AppSpacing.md),
            _buildTypeSelector(),
            const SizedBox(height: AppSpacing.md),
            _buildContentSection(),
            const SizedBox(height: AppSpacing.md),
            _buildPreviewCard(),
            const SizedBox(height: AppSpacing.md),
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.lg),
            _buildRecentNotifications(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Target Audience', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _audiences.map((audience) {
                final isSelected = _selectedAudience == audience;
                return ChoiceChip(
                  label: Text(audience),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedAudience = audience),
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  avatar: isSelected
                      ? const Icon(Icons.people, color: Colors.white, size: 14)
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Type', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _notifTypes.map((type) {
                final isSelected = _selectedTypes.contains(type);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => _toggleType(type),
                      selectedColor: AppColors.primary,
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Content', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Weekend Sale is Live!',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Body Message',
                hintText: 'Shop now and get up to 20% off on all orders...',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.image_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final hasContent = _titleController.text.isNotEmpty || _bodyController.text.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.preview_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                const Text('Preview', style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: hasContent
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.eco, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('GreenBasket', style: AppTextStyles.labelLarge),
                                  Text('now', style: AppTextStyles.labelSmall),
                                ],
                              ),
                              if (_titleController.text.isNotEmpty)
                                Text(_titleController.text, style: AppTextStyles.bodyMedium),
                              if (_bodyController.text.isNotEmpty)
                                Text(
                                  _bodyController.text,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'Fill in title and body to see preview',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _scheduleNotification,
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _sendNow,
            icon: const Icon(Icons.send),
            label: const Text('Send Now'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Notifications', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        ..._recentNotifications.map((notif) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(notif['title']!, style: AppTextStyles.labelLarge),
                        ),
                        Text(notif['sentAt']!, style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif['body']!, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(notif['audience']!,
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                        ),
                        const Spacer(),
                        const Icon(Icons.people_outline, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${notif['reach']} reached', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
