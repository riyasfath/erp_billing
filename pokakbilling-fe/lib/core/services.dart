import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'access_token';
  static const _emailKey = 'logged_in_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // In-memory backup. Shared by every SecureStorageService() instance, so a
  // flaky Keystore read on the emulator can't make the token "disappear"
  // right after login.
  static String? _cachedToken;

  // ── Token ─────────────────────────────────────────────────────────────────
  Future<void> storeToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
    debugPrint('[SecureStorage] STORE TOKEN (len ${token.length})');
  }

  Future<String?> getToken() async {
    String? token;
    try {
      token = await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('[SecureStorage] read error: $e');
    }

    if (token == null && _cachedToken != null) {
      debugPrint('[SecureStorage] storage returned NULL, using memory cache');
      token = _cachedToken;
    }

    debugPrint('[SecureStorage] GET TOKEN => ${token == null ? "NULL" : "OK"}');
    return token;
  }

  Future<void> deleteToken() async {
    // Tells us WHO deleted the token (look at the first lines of the trace).
    debugPrint('[SecureStorage] DELETE TOKEN called from:\n'
        '${StackTrace.current.toString().split("\n").take(8).join("\n")}');
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  // ── Email ─────────────────────────────────────────────────────────────────
  Future<void> storeEmail(String email) async {
    await _storage.write(key: _emailKey, value: email.trim().toLowerCase());
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> deleteEmail() async {
    await _storage.delete(key: _emailKey);
  }
}