import 'package:flutter/material.dart';
import 'package:greenbasket/core/constants/app_colors.dart';
import 'package:greenbasket/core/constants/app_spacing.dart';

/// Convenience extensions used throughout the app.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String get capitalizeWords =>
      split(' ').map((w) => w.capitalize).join(' ');
}

extension WidgetSpacing on num {
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

extension EdgeInsetsHelper on double {
  EdgeInsets get all => EdgeInsets.all(this);
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: this);
}

/// Standard screen padding.
EdgeInsets get screenPadding => const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
      vertical: AppSpacing.screenVertical,
    );
