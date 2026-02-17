/// Environment configuration loaded via --dart-define flags.
///
/// Run with:
/// ```
/// flutter run \
///   --dart-define=BASE_URL=http://localhost:6000 \
///   --dart-define=RAZORPAY_KEY=rzp_test_xxx \
///   --dart-define=ENVIRONMENT=dev
/// ```
class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: '',
  );

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';
}
