import 'package:greenbasket/core/constants/app_config.dart';

/// All API endpoint paths. Never hard-code URLs — read from [AppConfig.baseUrl].
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.baseUrl;

  // ── Auth ─────────────────────────────────────────────────────────────
  static const String signup = '/api/auth/user/signup';
  static const String login = '/api/auth/user/login';
  static const String verifyEmail = '/api/auth/user/verify-email';
  static const String forgotPassword = '/api/auth/user/forgot-password';
  static const String resetPassword = '/api/auth/user/reset-password';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';

  // ── Products ─────────────────────────────────────────────────────────
  static const String products = '/api/products';
  static const String productSearch = '/api/products/search';
  static String productById(String id) => '/api/products/$id';

  // ── Categories ───────────────────────────────────────────────────────
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // ── Cart ─────────────────────────────────────────────────────────────
  static const String cart = '/api/cart';
  static const String cartAdd = '/api/cart/add';
  static String cartUpdate(String productId) => '/api/cart/update/$productId';
  static String cartRemove(String productId) => '/api/cart/remove/$productId';
  static const String cartClear = '/api/cart/clear';
  static const String cartRecipe = '/api/cart/recipe-to-cart';

  // ── Orders ───────────────────────────────────────────────────────────
  static const String orders = '/api/orders';
  static const String myOrders = '/api/orders/my-orders';
  static String orderById(String id) => '/api/orders/$id';
  static String cancelOrder(String id) => '/api/orders/$id/cancel';

  // ── User ─────────────────────────────────────────────────────────────
  static const String userProfile = '/api/users/profile';
  static const String userAddresses = '/api/users/addresses';
  static String userAddressById(String id) => '/api/users/addresses/$id';
  static const String userFcmToken = '/api/users/fcm-token';

  // ── Wishlist ─────────────────────────────────────────────────────────
  static const String wishlist = '/api/wishlist';
  static const String wishlistAdd = '/api/wishlist/add';
  static String wishlistRemove(String productId) =>
      '/api/wishlist/remove/$productId';
  static String wishlistMoveToCart(String productId) =>
      '/api/wishlist/move-to-cart/$productId';
  static String wishlistCheck(String productId) =>
      '/api/wishlist/check/$productId';

  // ── Notifications ────────────────────────────────────────────────────
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static String notificationMarkRead(String id) =>
      '/api/notifications/$id/read';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static String notificationDelete(String id) => '/api/notifications/$id';
  static const String notificationsClearAll = '/api/notifications/clear-all';

  // ── Recipes ──────────────────────────────────────────────────────────
  static const String recipes = '/api/recipes';
  static const String recipesSearch = '/api/recipes/search';
  static String recipeById(String id) => '/api/recipes/$id';
  static String recipeCalculate(String id) =>
      '/api/recipes/$id/calculate-ingredients';

  // ── Search ───────────────────────────────────────────────────────────
  static const String searchProducts = '/api/search/products';
  static const String searchSuggestions = '/api/search/suggestions';
  static const String searchTrending = '/api/search/trending';

  // ── Wallet ───────────────────────────────────────────────────────────
  static const String wallet = '/api/wallet';
  static const String walletTransactions = '/api/wallet/transactions';
  static const String walletAddMoney = '/api/wallet/add-money';
  static const String walletVerifyTopup = '/api/wallet/verify-topup';

  // ── Offers / Coupons ─────────────────────────────────────────────────
  static const String offersAvailable = '/api/offers/available';
  static const String offersApplyCoupon = '/api/offers/cart/apply-coupon';
  static const String offersRemoveCoupon = '/api/offers/cart/remove-coupon';
  static const String offersFlashSales = '/api/offers/flash-sales';

  // ── Reviews ──────────────────────────────────────────────────────────
  static String productReviews(String productId) =>
      '/api/reviews/product/$productId';
  static const String reviewSubmit = '/api/reviews';

  // ── Payments ─────────────────────────────────────────────────────────
  static const String paymentCreateOrder = '/api/payment/create-order';
  static const String paymentVerify = '/api/payment/verify';
}
