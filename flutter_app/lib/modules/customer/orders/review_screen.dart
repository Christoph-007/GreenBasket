import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class _ReviewItem {
  final String id;
  final String name;
  final String unit;
  int rating;
  _ReviewItem({
    required this.id,
    required this.name,
    required this.unit,
    this.rating = 0,
  });
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // Mock order items — in production load from Get.arguments['orderId']
  final List<_ReviewItem> _items = [
    _ReviewItem(id: '1', name: 'Organic Spinach', unit: '250g'),
    _ReviewItem(id: '2', name: 'Fresh Tomatoes', unit: '500g'),
    _ReviewItem(id: '3', name: 'Alphonso Mangoes', unit: '3 pcs'),
  ];

  int _overallRating = 0;
  final _feedbackCtrl = TextEditingController();
  bool _hasPhoto = false;
  bool _isSubmitting = false;

  static const List<String> _ratingLabels = [
    '',
    'Terrible',
    'Poor',
    'Average',
    'Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overallRating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please rate your overall experience',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isSubmitting = true);
    // TODO: Submit review via API
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isSubmitting = false);
    Get.back();
    Get.snackbar(
      'Review Submitted!',
      'Thank you for your feedback',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
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
        title: const Text('Rate Your Order',
            style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item ratings
                  const Text('Rate Each Item',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: AppSpacing.md),
                      itemBuilder: (_, i) =>
                          _buildItemRatingRow(_items[i]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Overall experience
                  const Text('Overall Experience',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final starIndex = i + 1;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _overallRating = starIndex),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: Icon(
                                    starIndex <= _overallRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    key: ValueKey(
                                        'overall_${starIndex}_$_overallRating'),
                                    color: starIndex <= _overallRating
                                        ? AppColors.secondary
                                        : AppColors.textHint,
                                    size: 40,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_overallRating > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _ratingLabels[_overallRating],
                              key: ValueKey(_overallRating),
                              style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tell us more
                  const Text('Tell Us More',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _feedbackCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText:
                          'Share your experience — freshness, packaging, delivery...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Photo upload placeholder
                  GestureDetector(
                    onTap: () {
                      // TODO: Launch image picker
                      setState(() => _hasPhoto = !_hasPhoto);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _hasPhoto
                            ? AppColors.primaryContainer
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: _hasPhoto
                              ? AppColors.primary
                              : AppColors.border,
                          style: BorderStyle.solid,
                          width: _hasPhoto ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasPhoto
                                ? Icons.check_circle_rounded
                                : Icons.add_a_photo_outlined,
                            color: _hasPhoto
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _hasPhoto
                                ? 'Photo Added'
                                : 'Add Photos (Optional)',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: _hasPhoto
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, -2)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRatingRow(_ReviewItem item) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.eco_outlined,
              color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: AppTextStyles.titleMedium),
              Text(item.unit, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        // Star rating
        Row(
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return GestureDetector(
              onTap: () => setState(() => item.rating = starIndex),
              child: Icon(
                starIndex <= item.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: starIndex <= item.rating
                    ? AppColors.secondary
                    : AppColors.textHint,
                size: 22,
              ),
            );
          }),
        ),
      ],
    );
  }
}
