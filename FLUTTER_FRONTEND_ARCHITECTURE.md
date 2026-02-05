# Green Basket - Flutter Frontend Architecture

This document outlines a **scalable, feature-first architecture** for the Green Basket mobile application (User/Consumer App). This structure is designed to handle the complex feature set (Recipes, Subscriptions, Real-time tracking) while keeping code maintainable.

## 1. Recommended Tech Stack
*   **Framework**: Flutter (Supports iOS, Android, Web)
*   **State Management**: **flutter_riverpod** (Flexible & Testable) or **flutter_bloc** (Strict & Enterprise-grade). *Recommendation: Riverpod 2.0+*
*   **Navigation**: **go_router** (Deep linking, nested routes for web support)
*   **Networking**: **dio** (Interceptors for auth token handling)
*   **Local Storage**: **hive** or **shared_preferences** (Auth tokens, settings) or **isar** (Offline caching)
*   **Maps**: **google_maps_flutter**
*   **Payments**: **razorpay_flutter** / **stripe_flutter**
*   **Notifications**: **firebase_messaging**
*   **Real-time**: **socket_io_client** (For order tracking, chat)

## 2. Project Folder Structure (Feature-First)

The `lib` folder is divided into `core` (infra) and `features` (business logic).

```
lib/
├── main.dart                  # Entry point (Env config, Providers scope)
├── app.dart                   # Global providers, Theme setup, Router config
├── config/
│   ├── theme/                 # AppTheme, Colors, Typography (Google Fonts)
│   ├── routes/                # GoRouter configuration
│   └── constants/             # API Endpoints, Asset Paths, Strings
├── core/                      # Global / Low-level code
│   ├── api/                   # Dio Client, Interceptors (Auth headers)
│   ├── error/                 # Failure classes, Exceptions
│   ├── utils/                 # Date formatters, Validators, Currency helpers
│   ├── widgets/               # Global shared widgets (Buttons, Input fields, Loaders)
│   └── services/              # Global services (StorageService, LocationService)
└── features/                  # Independent Modules
    ├── auth/                  # Login, Signup, OTP, Forgot Pwd
    │   ├── data/              # Repositories, DTOs
    │   ├── domain/            # Entities, UseCases (optional)
    │   ├── presentation/      # Screens (LoginScreen), States (AuthController)
    │   └── widgets/           # Auth-specific widgets (e.g. SocialLoginButton)
    ├── home/                  # Dashboard, Featured items, Banner slider
    ├── product/               # Product Listing, Detail, Search, Filters
    │   └── presentation/widgets/ # ProductCard, FilterBottomSheet
    ├── cart/                  # Cart logic, Calculations, Recipe-to-Cart logic
    ├── recipe/                # Smart Calculator, Recipe Detail, Cooking Mode
    │   └── logic/             # IngredientScalingLogic
    ├── checkout/              # Address selection, Payment gateway ,,,,,km m,,,,,,,,d          # Chat UI, Ticket creation
```

## 3. Feature Logic Breakdown

### A. Authentication Module (`features/auth`)
*   **Screens**: `LoginScreen`, `SignupScreen`, `VerifyOtpScreen`, `OnboardingScreen`.
*   **Logic**: Handle JWT storage, Auto-login on app start.

### B. Smart Recipe Module (`features/recipe`)
*   **Unique UI**:
    *   `ServingSizeSelector`: Slider/Input to change servings (2 -> 4).
    *   `IngredientList`: Toggleable list (Check ingredients you already have).
    *   `CookingMode`: Full-screen step-by-step video/text view.
*   **Logic**: `RecipeCalculator` (Dart version of backend logic) to estimate prices locally before API call.

### C. Shopping & Cart (`features/product`, `features/cart`)
*   **UI**:
    *   `ProductGrid`: With "Add" buttons that become (+ 1 -) counters.
    *   `FloatingCartBar`: Shows total and "View Cart" on bottom.
*   **State**: `CartNotifier` needs to be global or accessible from Product screens.

### D. Order & Tracking (`features/order`)
*   **Maps Integration**:
    *   `TrackingScreen`: distinct layout with Map taking 60% height, status sheet at bottom.
    *   **Socket**: Listen to `order_update` events to move driver pin on map live.

### E. Subscription (`features/subscription`)
*   **Calendar View**: Custom calendar widget to show upcoming deliveries.
*   **Box Customizer**: Drag-and-drop or checklist UI to swap veggies in a box.

## 4. Shared Widgets (`core/widgets`)
To maintain the "Premium Aesthetic":
*   `GlassContainer`: For Glassmorphism effects (cards/dialogs).
*   `PrimaryButton`: Gradient background, rounded corners.
*   `QuantitySelector`: Stylish plus/minus widget.
*   `NetworkImageWithLoader`: Wrapper for CachedNetworkImage.
*   `RatingBadge`: Star icon with rating number.

## 5. Development Phases

### Phase 1: Core Commerce
1.  Setup `Dio` and Auth.
2.  Product Feed & Search.
3.  Cart & Checkout (Order placement).
4.  Order History.

### Phase 2: Smart Features
1.  Recipe Listings & Scaling Logic.
2.  Add Recipe to Cart flow.
3.  Calculated Cart summary.

### Phase 3: Engagement
1.  Loyalty Profile (`features/loyalty`).
2.  Wallet & Referrals (`features/wallet`).
3.  Support Chat (`features/support`).

### Phase 4: Polish
1.  Animations (Hero transitions).
2.  Skeleton Loaders.
3.  Dark Mode toggle.
