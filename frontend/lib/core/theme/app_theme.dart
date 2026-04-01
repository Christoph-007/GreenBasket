import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenbasket/core/constants/app_colors.dart';
import 'package:greenbasket/core/constants/app_radius.dart';
import 'package:greenbasket/core/constants/app_typography.dart';

/// Light theme configuration matching the GreenBasket Design System.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',

      // ── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorLight,
        surface: AppColors.white,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral100,
      ),
      scaffoldBackgroundColor: AppColors.neutral50,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 2,
        scrolledUnderElevation: 2,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTypography.headingLg,
        iconTheme: const IconThemeData(
          color: AppColors.neutral900,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral500,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        elevation: 4,
        showUnselectedLabels: true,
      ),

      // ── Elevated Button (Primary) ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderSm,
          ),
          textStyle: AppTypography.buttonLg,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderSm,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.buttonLg.copyWith(color: AppColors.primary),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMd.copyWith(color: AppColors.primary),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.neutral500),
        labelStyle: AppTypography.titleSm.copyWith(color: AppColors.neutral700),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: BorderSide(
            color: AppColors.neutral300.withValues(alpha: 0.6),
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primarySurface,
        labelStyle: AppTypography.bodyMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXs,
        ),
        side: const BorderSide(color: AppColors.neutral300),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral300,
        thickness: 1,
        space: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
        ),
        titleTextStyle: AppTypography.headingMd,
        contentTextStyle: AppTypography.bodyMd,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.neutral300,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
        ),
        contentTextStyle: AppTypography.bodyMd.copyWith(color: AppColors.white),
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral500,
        labelStyle: AppTypography.titleMd,
        unselectedLabelStyle: AppTypography.titleMd,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // ── Progress Indicator ────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primarySurface,
      ),
    );
  }
}
