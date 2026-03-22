class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:3000/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
  static const String onboardedKey = 'onboarded';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleMerchant = 'merchant';
  static const String roleAdmin = 'admin';
  static const String roleAgent = 'delivery_agent';

  // App info
  static const String appName = 'GreenBasket';
  static const String appVersion = '1.0.0';

  // OTP resend timer (seconds)
  static const int otpResendSeconds = 60;

  // Image quality
  static const int imageCacheWidth = 800;
}
