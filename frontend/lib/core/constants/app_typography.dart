import 'package:flutter/material.dart';
import 'package:greenbasket/core/constants/app_colors.dart';

/// 17 typography styles exactly matching the Design System (Section 3.2).
///
/// Font family: Poppins (weights 400, 500, 600, 700).
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Poppins';

  // ── Display ────────────────────────────────────────────────────────────
  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.5,
    color: AppColors.neutral900,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.25,
    color: AppColors.neutral900,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: 0,
    color: AppColors.neutral900,
  );

  // ── Heading ────────────────────────────────────────────────────────────
  static const TextStyle headingLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: 0,
    color: AppColors.neutral900,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 26 / 20,
    letterSpacing: 0,
    color: AppColors.neutral900,
  );

  static const TextStyle headingSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: 0,
    color: AppColors.neutral900,
  );

  // ── Title ──────────────────────────────────────────────────────────────
  static const TextStyle titleLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    letterSpacing: 0.15,
    color: AppColors.neutral900,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.1,
    color: AppColors.neutral900,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
    letterSpacing: 0.1,
    color: AppColors.neutral900,
  );

  // ── Body ───────────────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
    color: AppColors.neutral900,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
    color: AppColors.neutral900,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
    letterSpacing: 0.4,
    color: AppColors.neutral900,
  );

  // ── Caption & Overline ─────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    letterSpacing: 0.4,
    color: AppColors.neutral900,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
    letterSpacing: 1.5,
    color: AppColors.neutral900,
  );

  // ── Button ─────────────────────────────────────────────────────────────
  static const TextStyle buttonLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    letterSpacing: 0.5,
    color: AppColors.white,
  );

  static const TextStyle buttonMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
    letterSpacing: 0.5,
    color: AppColors.white,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.5,
    color: AppColors.white,
  );
}
