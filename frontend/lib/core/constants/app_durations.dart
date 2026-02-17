/// 8 animation-duration tokens from the Design System (Section 3.7).
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration splash = Duration(milliseconds: 2000);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration success = Duration(milliseconds: 1200);
  static const Duration button = Duration(milliseconds: 100);

  /// Search debounce duration (rxdart debounceTime).
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Banner auto-scroll interval.
  static const Duration bannerAutoScroll = Duration(seconds: 5);

  /// OTP resend countdown.
  static const Duration otpResend = Duration(seconds: 30);
}
