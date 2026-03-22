class Routes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';

  // Customer
  static const String customerHome = '/customer/home';
  static const String categories = '/customer/categories';
  static const String productDetail = '/customer/product/:id';
  static const String search = '/customer/search';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String orderList = '/customer/orders';
  static const String orderDetail = '/customer/orders/:id';
  static const String profile = '/customer/profile';
  static const String wallet = '/customer/wallet';
  static const String loyalty = '/customer/loyalty';
  static const String wishlist = '/customer/wishlist';
  static const String notifications = '/customer/notifications';
  static const String addresses = '/customer/addresses';
  static const String referral = '/customer/referral';
  static const String giftCards = '/customer/gift-cards';
  static const String membership = '/customer/membership';
  static const String disputes = '/customer/disputes';
  static const String returns = '/customer/returns';
  static const String recipes = '/customer/recipes';
  static const String recipeDetail = '/customer/recipes/:id';

  // Merchant
  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantProducts = '/merchant/products';
  static const String merchantOrders = '/merchant/orders';
  static const String merchantAnalytics = '/merchant/analytics';
  static const String merchantProfile = '/merchant/profile';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminMerchants = '/admin/merchants';
  static const String adminOrders = '/admin/orders';
  static const String adminFinance = '/admin/finance';

  // Delivery Agent
  static const String agentCurrentJob = '/agent/job';
  static const String agentHistory = '/agent/history';
  static const String agentEarnings = '/agent/earnings';
  static const String agentProfile = '/agent/profile';
}
