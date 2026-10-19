import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists auth tokens (and the last known email) in the device's
/// secure storage (Keychain on iOS, Keystore-backed EncryptedSharedPreferences
/// on Android). Never store tokens in plain SharedPreferences.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _recentlyViewedKey = 'recently_viewed_products';
  static const _favoritesKey = 'favorite_product_ids';

  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await _storage.write(key: _accessKey, value: accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Call once, the first time the onboarding screens finish (e.g. on
  /// "Get Started" / "Skip"). This is about the DEVICE, not any one
  /// login — it must NOT be cleared by [clear] on logout, or
  /// onboarding would wrongly show again for the next person who logs
  /// in on this same device.
  Future<void> setOnboardingSeen() =>
      _storage.write(key: _onboardingSeenKey, value: 'true');

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _onboardingSeenKey);
    return value == 'true';
  }

  /// JSON-encoded list of recently-viewed ProductModel.toJson() maps.
  /// Unlike onboarding, this IS cleared by [clear] on logout — it's
  /// personal browsing history, not a device-level flag.
  Future<void> saveRecentlyViewedJson(String json) =>
      _storage.write(key: _recentlyViewedKey, value: json);

  Future<String?> getRecentlyViewedJson() => _storage.read(key: _recentlyViewedKey);

  /// JSON-encoded list of favorited product IDs (strings). No backend
  /// wishlist endpoint exists — persisted locally the same way
  /// recently-viewed is, and cleared on logout since it's personal.
  Future<void> saveFavoritesJson(String json) =>
      _storage.write(key: _favoritesKey, value: json);

  Future<String?> getFavoritesJson() => _storage.read(key: _favoritesKey);

  /// Clears the session (tokens + email) and personal data (browsing
  /// history, favorites) on logout. Deliberately does NOT touch the
  /// onboarding-seen flag — see [setOnboardingSeen].
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _recentlyViewedKey);
    await _storage.delete(key: _favoritesKey);
  }
}