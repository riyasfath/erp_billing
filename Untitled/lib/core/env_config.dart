import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to values loaded from the root `.env` file.
/// Call `EnvConfig.load()` once in `main()` before `runApp`.
/// Full endpoint URLs are built in `providers.dart` (ApiEndpoints), not
/// here — this file only exposes the raw base URLs.
class EnvConfig {
  EnvConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Base URL for register / register-verify.
  static String get accountsBaseUrl => dotenv.env['ACCOUNTS_BASE_URL'] ?? '';

  /// Base URL for login.
  static String get authBaseUrl => dotenv.env['AUTH_BASE_URL'] ?? '';

  /// Base URL for product endpoints — add PRODUCT_BASE_URL to .env once
  /// you have it.
  static String get productBaseUrl => dotenv.env['PRODUCT_BASE_URL'] ?? '';

  /// Google OAuth Web Client ID (Google Cloud Console / Firebase).
  /// The ID token's `aud` claim must match what your backend verifies
  /// against for /auth/social/. Required on Android (GoogleSignIn's
  /// serverClientId); harmless extra safety to also set on iOS.
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

  /// Razorpay checkout key_id — used ONLY as a fallback if the
  /// create-order response doesn't already include one. Add
  /// RAZORPAY_KEY_ID=... to .env when you have it (can stay blank
  /// for now).
  static String get razorpayKeyId => dotenv.env['RAZORPAY_KEY_ID'] ?? '';
}