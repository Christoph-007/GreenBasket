/// All user-visible string constants, organized by screen / feature.
///
/// No string literals in any widget `build()` method — use this class instead.
/// This prepares for i18n without requiring ARB files now.
class AppStrings {
  AppStrings._();

  // ── App-wide ─────────────────────────────────────────────────────────
  static const String appName = 'GreenBasket';
  static const String appTagline = 'Farm Fresh to Your Door';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String seeAll = 'See All';
  static const String apply = 'Apply';
  static const String remove = 'Remove';
  static const String loading = 'Loading...';
  static const String offlineBanner =
      "You're offline — some features may not work";

  // ── Onboarding ───────────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Fresh from the Farm';
  static const String onboardingDesc1 =
      'Browse categories of farm-fresh produce harvested daily';
  static const String onboardingTitle2 = 'Easy Ordering';
  static const String onboardingDesc2 =
      'Add to cart, choose delivery time, pay your way';
  static const String onboardingTitle3 = 'Fast Delivery';
  static const String onboardingDesc3 =
      'Track your order in real-time from farm to door';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  // ── Auth — Login ─────────────────────────────────────────────────────
  static const String welcomeBack = 'Welcome back!';
  static const String loginSubtitle = 'Log in to continue';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?';
  static const String logIn = 'Log In';
  static const String or = 'or';
  static const String continueWithGoogle = 'Continue with Google';
  static const String noAccount = "Don't have an account? ";
  static const String signUpLink = 'Sign Up';

  // ── Auth — Sign Up ───────────────────────────────────────────────────
  static const String createAccount = 'Create Account';
  static const String signupSubtitle = 'Join GreenBasket today';
  static const String fullNameHint = 'Enter full name';
  static const String phoneHint = 'Enter 10-digit number';
  static const String createPasswordHint = 'Create a password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String termsPrefix = 'I agree to the ';
  static const String termsLink = 'Terms';
  static const String and = ' and ';
  static const String privacyLink = 'Privacy Policy';
  static const String createAccountBtn = 'Create Account';
  static const String hasAccount = 'Already have an account? ';
  static const String logInLink = 'Log In';

  // ── Auth — Forgot Password ───────────────────────────────────────────
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordDesc =
      'Enter your email to receive a reset link';
  static const String sendResetLink = 'Send Reset Link';

  // ── Auth — OTP ───────────────────────────────────────────────────────
  static const String verifyEmail = 'Verify Email';
  static const String otpSentTo = 'We sent a code to ';
  static const String resendIn = 'Resend in ';
  static const String resendCode = 'Resend Code';

  // ── Home ─────────────────────────────────────────────────────────────
  static const String deliverTo = 'Deliver to';
  static const String searchHint = 'Search fruits, vegetables...';
  static const String shopByCategory = 'Shop by Category';
  static const String flashDeals = 'Flash Deals';
  static const String popularNow = 'Popular Now';
  static const String recipeInspiration = 'Recipe Inspiration';
  static const String recentlyViewed = 'Recently Viewed';

  // ── Bottom Nav ───────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navCategories = 'Categories';
  static const String navCart = 'Cart';
  static const String navWishlist = 'Wishlist';
  static const String navProfile = 'Profile';

  // ── Categories ───────────────────────────────────────────────────────
  static const String categoriesTitle = 'Categories';

  // ── Product Listing ──────────────────────────────────────────────────
  static const String filterAll = 'All';
  static const String filterOrganic = 'Organic';
  static const String filterBestSeller = 'Best Seller';
  static const String filterOnSale = 'On Sale';
  static const String sortBy = 'Sort By';
  static const String sortRelevance = 'Relevance';
  static const String sortPriceLowHigh = 'Price: Low to High';
  static const String sortPriceHighLow = 'Price: High to Low';
  static const String sortNewest = 'Newest First';
  static const String sortRating = 'Rating';
  static const String filterTitle = 'Filter';
  static const String priceRange = 'Price Range';
  static const String tags = 'Tags';
  static const String ratingLabel = 'Rating';
  static const String availability = 'Availability';
  static const String inStock = 'In Stock';
  static const String reset = 'Reset';
  static const String noProductsFound = 'No products found';
  static const String tryAdjustingFilters = 'Try adjusting filters';
  static const String clearFilters = 'Clear Filters';

  // ── Product Detail ───────────────────────────────────────────────────
  static const String addToCart = 'Add to Cart';
  static const String preparation = 'Preparation';
  static const String aboutThisProduct = 'About this product';
  static const String readMore = 'Read more';
  static const String readLess = 'Read less';
  static const String nutritionalInfo = 'Nutritional Info';
  static const String originQuality = 'Origin & Quality';
  static const String reviews = 'Reviews';
  static const String youMightAlsoLike = 'You might also like';
  static const String perUnit = 'per';
  static const String off = 'OFF';

  // ── Search ───────────────────────────────────────────────────────────
  static const String recentSearches = 'Recent Searches';
  static const String trendingSearches = 'Trending Searches';
  static const String resultsFor = 'results for';

  // ── Cart ─────────────────────────────────────────────────────────────
  static const String myCart = 'My Cart';
  static const String clearAll = 'Clear All';
  static const String clearCartConfirm = 'Are you sure you want to clear all items from your cart?';
  static const String emptyCartTitle = 'Your cart is empty';
  static const String emptyCartSubtitle = 'Browse products to get started';
  static const String startShopping = 'Start Shopping';
  static const String applyCoupon = 'Apply Coupon';
  static const String itemsTotal = 'Items total';
  static const String delivery = 'Delivery';
  static const String free = 'FREE';
  static const String discountLabel = 'Discount';
  static const String total = 'Total';
  static const String proceedToCheckout = 'Proceed to Checkout';

  // ── Checkout ─────────────────────────────────────────────────────────
  static const String stepAddress = 'Address';
  static const String stepDelivery = 'Delivery';
  static const String stepPayment = 'Payment';
  static const String stepReview = 'Review';
  static const String addNewAddress = '+ Add New Address';
  static const String continueBtn = 'Continue';
  static const String onlinePayment = 'Online Payment';
  static const String walletBalance = 'Wallet Balance';
  static const String cashOnDelivery = 'Cash on Delivery';
  static const String placeOrder = 'Place Order';

  // ── Order Success ────────────────────────────────────────────────────
  static const String orderPlaced = 'Order Placed!';
  static const String orderPlacedMessage = 'Your order has been placed';
  static const String trackOrder = 'Track Order';
  static const String continueShopping = 'Continue Shopping';

  // ── Orders ───────────────────────────────────────────────────────────
  static const String myOrders = 'My Orders';
  static const String tabAll = 'All';
  static const String tabActive = 'Active';
  static const String tabCompleted = 'Completed';
  static const String tabCancelled = 'Cancelled';
  static const String noOrdersYet = 'No orders yet';
  static const String noOrdersSubtitle = 'Start shopping to see your orders';
  static const String track = 'Track';

  // ── Order Detail ─────────────────────────────────────────────────────
  static const String help = 'Help';
  static const String cancelOrder = 'Cancel Order';
  static const String cancelOrderConfirm =
      'Are you sure you want to cancel this order?';
  static const String rateOrder = 'Rate Order';
  static const String reorder = 'Reorder';

  // ── Profile ──────────────────────────────────────────────────────────
  static const String myOrdersMenu = 'My Orders';
  static const String myAddresses = 'My Addresses';
  static const String walletMenu = 'Wallet';
  static const String loyaltyPoints = 'Loyalty Points';
  static const String referrals = 'Referrals';
  static const String recipesMenu = 'Recipes';
  static const String settings = 'Settings';
  static const String helpSupport = 'Help & Support';
  static const String logOut = 'Log Out';
  static const String logOutConfirm = 'Are you sure you want to log out?';
  static const String goldMember = 'Gold Member';

  // ── Edit Profile ─────────────────────────────────────────────────────
  static const String editProfile = 'Edit Profile';
  static const String dietaryPreferences = 'Dietary Preferences';
  static const String vegetarian = 'Vegetarian';
  static const String vegan = 'Vegan';
  static const String nonVegetarian = 'Non-Vegetarian';
  static const String glutenFree = 'Gluten-Free';
  static const String organicOnly = 'Organic Only';
  static const String allergies = 'Allergies';

  // ── Addresses ────────────────────────────────────────────────────────
  static const String addAddress = 'Add Address';
  static const String editAddress = 'Edit Address';
  static const String labelHome = 'Home';
  static const String labelOffice = 'Office';
  static const String labelOther = 'Other';
  static const String defaultBadge = 'Default';
  static const String addressLine1Hint = 'Address Line 1';
  static const String addressLine2Hint = 'Address Line 2 (Optional)';
  static const String landmarkHint = 'Landmark (Optional)';
  static const String cityHint = 'City';
  static const String stateHint = 'State';
  static const String pincodeHint = 'Pincode';
  static const String setAsDefault = 'Set as Default';

  // ── Wishlist ─────────────────────────────────────────────────────────
  static const String wishlistTitle = 'Wishlist';
  static const String emptyWishlistTitle = 'Your wishlist is empty';
  static const String emptyWishlistSubtitle = 'Explore products to add to your wishlist';
  static const String exploreProducts = 'Explore Products';
  static const String moveToCart = 'Move to Cart';

  // ── Notifications ────────────────────────────────────────────────────
  static const String notificationsTitle = 'Notifications';
  static const String markAllRead = 'Mark All Read';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String earlier = 'Earlier';
  static const String noNotifications = 'No notifications';
  static const String noNotificationsSubtitle =
      "We'll notify you about orders and offers";

  // ── Settings ─────────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String notificationPreferences = 'Notification Preferences';
  static const String orderUpdates = 'Order Updates';
  static const String offers = 'Offers';
  static const String priceDrops = 'Price Drops';
  static const String backInStock = 'Back in Stock';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String about = 'About';
  static const String appVersion = 'App Version';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String openSourceLicenses = 'Open Source Licenses';
  static const String dangerZone = 'Danger Zone';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirm =
      'This action is irreversible. Enter your password to confirm.';

  // ── Wallet ───────────────────────────────────────────────────────────
  static const String walletTitle = 'Wallet';
  static const String balance = 'Balance';
  static const String addMoney = 'Add Money';
  static const String transactionHistory = 'Transaction History';

  // ── Recipes ──────────────────────────────────────────────────────────
  static const String recipesTitle = 'Recipes';
  static const String ingredients = 'Ingredients';
  static const String instructions = 'Instructions';
  static const String addIngredientsToCart = 'Add Ingredients to Cart';
  static const String servings = 'servings';
  static const String prepTime = 'Prep';
  static const String cookTime = 'Cook';
  static const String mins = 'mins';

  // ── Validation messages ──────────────────────────────────────────────
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid 10-digit number';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordRequirements =
      'Password must contain at least 1 uppercase letter and 1 number';
  static const String passwordsMismatch = 'Passwords do not match';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String nameTooLong = 'Name must not exceed 50 characters';
  static const String invalidPincode = 'Please enter a valid 6-digit pincode';
  static const String invalidOtp = 'Please enter a valid 6-digit OTP';

  // ── Snackbar / Toasts ────────────────────────────────────────────────
  static const String addedToCart = 'Added to cart';
  static const String removedFromCart = 'Removed from cart';
  static const String addedToWishlist = 'Added to wishlist';
  static const String removedFromWishlist = 'Removed from wishlist';
  static const String couponApplied = 'Coupon applied';
  static const String couponRemoved = 'Coupon removed';
  static const String profileUpdated = 'Profile updated';
  static const String addressSaved = 'Address saved';
  static const String addressDeleted = 'Address deleted';
  static const String somethingWentWrong = 'Something went wrong';
  static const String undo = 'Undo';
}
