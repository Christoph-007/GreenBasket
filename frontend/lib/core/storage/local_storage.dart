import 'package:hive_flutter/hive_flutter.dart';

/// Provides access to Hive boxes opened during [bootstrap].
class LocalStorageService {
  Box<dynamic> get cartBox => Hive.box<dynamic>('cart_box');
  Box<dynamic> get searchBox => Hive.box<dynamic>('search_box');
  Box<dynamic> get prefsBox => Hive.box<dynamic>('prefs_box');
  Box<dynamic> get productCache => Hive.box<dynamic>('product_cache');
  Box<dynamic> get userCache => Hive.box<dynamic>('user_cache');

  // ── Prefs helpers ──────────────────────────────────────────────────
  bool get hasSeenOnboarding =>
      prefsBox.get('onboarding_seen', defaultValue: false) as bool;

  Future<void> setOnboardingSeen() => prefsBox.put('onboarding_seen', true);

  // ── Cache helpers with TTL ─────────────────────────────────────────
  Future<void> putWithTtl(
    Box<dynamic> box,
    String key,
    dynamic value,
    Duration ttl,
  ) async {
    await box.put(key, value);
    await box.put('${key}_expiry', DateTime.now().add(ttl).toIso8601String());
  }

  dynamic getIfValid(Box<dynamic> box, String key) {
    final expiryStr = box.get('${key}_expiry') as String?;
    if (expiryStr == null) return null;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      box.delete(key);
      box.delete('${key}_expiry');
      return null;
    }
    return box.get(key);
  }
}
