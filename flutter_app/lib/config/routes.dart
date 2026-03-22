class Routes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';

  // Customer shell
  static const String customerHome = '/customer/home';

  // Customer standalone
  static const String categories = '/customer/categories';
  static const String categoryDetail = '/customer/category-detail';
  static const String productDetail = '/customer/product/:id';
  static const String search = '/customer/search';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String payment = '/customer/payment';
  static const String orderSuccess = '/customer/order-success';
  static const String orderList = '/customer/orders';
  static const String orderDetail = '/customer/orders/:id';
  static const String orderTracking = '/customer/orders/track';
  static const String reviewOrder = '/customer/review';
  static const String profile = '/customer/profile';
  static const String editProfile = '/customer/profile/edit';
  static const String wallet = '/customer/wallet';
  static const String loyalty = '/customer/loyalty';
  static const String wishlist = '/customer/wishlist';
  static const String notifications = '/customer/notifications';
  static const String addresses = '/customer/addresses';
  static const String addAddress = '/customer/address/add';
  static const String referral = '/customer/referral';
  static const String giftCards = '/customer/gift-cards';
  static const String membership = '/customer/membership';
  static const String disputes = '/customer/disputes';
  static const String returns = '/customer/returns';
  static const String recipes = '/customer/recipes';
  static const String recipeDetail = '/customer/recipes/detail';

  // Merchant shell
  static const String merchantDashboard = '/merchant/dashboard';

  // Merchant standalone
  static const String merchantProducts = '/merchant/products';
  static const String merchantAddProduct = '/merchant/product/add';
  static const String merchantEditProduct = '/merchant/product/edit';
  static const String merchantProductStock = '/merchant/product/stock';
  static const String merchantBulkUpload = '/merchant/bulk-upload';
  static const String merchantOrders = '/merchant/orders';
  static const String merchantOrderDetail = '/merchant/order/detail';
  static const String merchantAnalytics = '/merchant/analytics';
  static const String merchantProfile = '/merchant/profile';
  static const String merchantOffers = '/merchant/offers';
  static const String merchantCreateOffer = '/merchant/offer/create';
  static const String merchantOfferAnalytics = '/merchant/offer/analytics';
  static const String merchantDocuments = '/merchant/documents';
  static const String merchantUploadDocument = '/merchant/document/upload';
  static const String merchantZones = '/merchant/zones';
  static const String merchantEditZone = '/merchant/zone/edit';
  static const String merchantFinancial = '/merchant/financial';
  static const String merchantPayouts = '/merchant/payouts';
  static const String merchantSettings = '/merchant/settings';
  static const String merchantSubscriptions = '/merchant/subscriptions';

  // Admin shell
  static const String adminDashboard = '/admin/dashboard';

  // Admin standalone
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/user/detail';
  static const String adminMerchants = '/admin/merchants';
  static const String adminVerifyMerchant = '/admin/merchant/verify';
  static const String adminMerchantAnalytics = '/admin/merchant/analytics';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/order/detail';
  static const String adminDisputes = '/admin/disputes';
  static const String adminReturns = '/admin/returns';
  static const String adminAssignOrder = '/admin/order/assign';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminCreateCategory = '/admin/category/create';
  static const String adminRecipes = '/admin/recipes';
  static const String adminCreateRecipe = '/admin/recipe/create';
  static const String adminAgents = '/admin/agents';
  static const String adminAgentDetail = '/admin/agent/detail';
  static const String adminAgentTrack = '/admin/agent/track';
  static const String adminGiftCards = '/admin/gift-cards';
  static const String adminGenerateGiftCard = '/admin/gift-card/generate';
  static const String adminOffers = '/admin/offers';
  static const String adminMembershipPlans = '/admin/membership/plans';
  static const String adminSubscribers = '/admin/membership/subscribers';
  static const String adminPayouts = '/admin/payouts';
  static const String adminCommission = '/admin/commission';
  static const String adminBulkOps = '/admin/bulk-ops';
  static const String adminSettings = '/admin/settings';
  static const String adminNotifications = '/admin/notifications';
  static const String adminFinance = '/admin/finance';

  // Delivery Agent shell
  static const String agentDashboard = '/agent/dashboard';

  // Delivery Agent standalone
  static const String agentCurrentJob = '/agent/job';
  static const String agentHistory = '/agent/history';
  static const String agentJobDetail = '/agent/job/detail';
  static const String agentNavigate = '/agent/navigate';
  static const String agentEarnings = '/agent/earnings';
  static const String agentEarningDetail = '/agent/earnings/detail';
  static const String agentProfile = '/agent/profile';
  static const String agentEditProfile = '/agent/profile/edit';
  static const String agentDocuments = '/agent/documents';
  static const String agentSettings = '/agent/settings';
}
