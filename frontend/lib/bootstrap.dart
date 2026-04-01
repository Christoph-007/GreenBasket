import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:greenbasket/core/constants/app_config.dart';
import 'package:greenbasket/core/di/injection.dart';

/// Initializes all app dependencies before runApp.
///
/// Fires debug-mode assertions if any required --dart-define value is missing.
Future<void> bootstrap() async {
  // ── Runtime assertions (debug only) ──────────────────────────────────────
  assert(
    AppConfig.baseUrl.isNotEmpty,
    'BASE_URL dart-define is missing. '
    'Run with: --dart-define=BASE_URL=http://localhost:6000',
  );
  assert(
    AppConfig.razorpayKey.isNotEmpty,
    'RAZORPAY_KEY dart-define is missing. '
    'Run with: --dart-define=RAZORPAY_KEY=rzp_test_xxx',
  );
  assert(
    AppConfig.environment.isNotEmpty,
    'ENVIRONMENT dart-define is missing. '
    'Run with: --dart-define=ENVIRONMENT=dev',
  );

  // ── Hive (local storage) ─────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('cart_box');
  await Hive.openBox<dynamic>('search_box');
  await Hive.openBox<dynamic>('prefs_box');
  await Hive.openBox<dynamic>('product_cache');
  await Hive.openBox<dynamic>('user_cache');

  // ── Dependency Injection ─────────────────────────────────────────────────
  configureDependencies();

  // ── Bloc observer (debug only) ───────────────────────────────────────────
  if (kDebugMode) {
    Bloc.observer = _AppBlocObserver();
  }
}

/// Minimal Bloc observer that logs transitions in debug mode.
class _AppBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('[Bloc] ${bloc.runtimeType} $transition');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('[Bloc] ${bloc.runtimeType} ERROR: $error');
    }
  }
}
