import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for JWT token persistence.
class SecureStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Access Token ───────────────────────────────────────────────────
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  // ── Refresh Token ──────────────────────────────────────────────────
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  // ── Clear ──────────────────────────────────────────────────────────
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
