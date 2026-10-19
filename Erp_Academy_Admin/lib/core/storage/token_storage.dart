import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session saved on the device.
class StoredSession {
  final String access;
  final String refresh;
  final int userId;
  final String email;
  final bool isSuperuser;
  final bool remember;

  const StoredSession({
    required this.access,
    required this.refresh,
    required this.userId,
    required this.email,
    required this.isSuperuser,
    required this.remember,
  });
}

/// Stores JWT tokens and basic session info securely on device.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kEmail = 'user_email';
  static const _kIsSuperuser = 'is_superuser';
  static const _kRemember = 'remember_device';

  // In-memory copy so the Dio interceptor doesn't hit storage every request.
  String? _accessCache;

  Future<void> saveSession({
    required String access,
    required String refresh,
    required int userId,
    required String email,
    required bool isSuperuser,
    required bool remember,
  }) async {
    _accessCache = access;
    await Future.wait([
      _storage.write(key: _kAccess, value: access),
      _storage.write(key: _kRefresh, value: refresh),
      _storage.write(key: _kUserId, value: userId.toString()),
      _storage.write(key: _kEmail, value: email),
      _storage.write(key: _kIsSuperuser, value: isSuperuser.toString()),
      _storage.write(key: _kRemember, value: remember.toString()),
    ]);
  }

  /// Reads the saved session. Returns null if nothing usable is saved.
  Future<StoredSession?> readSession() async {
    try {
      final all = await _storage.readAll();
      final access = all[_kAccess];
      if (access == null || access.isEmpty) return null;
      return StoredSession(
        access: access,
        refresh: all[_kRefresh] ?? '',
        userId: int.tryParse(all[_kUserId] ?? '') ?? 0,
        email: all[_kEmail] ?? '',
        isSuperuser: all[_kIsSuperuser] == 'true',
        remember: all[_kRemember] == 'true',
      );
    } catch (_) {
      // Corrupted storage (e.g. after reinstall on Android) → start fresh
      await clear();
      return null;
    }
  }

  /// Keeps the token only in memory (used when "Remember this device" is off).
  void setInMemoryAccess(String access) => _accessCache = access;

  Future<String?> get accessToken async =>
      _accessCache ??= await _storage.read(key: _kAccess);

  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    _accessCache = null;
    await _storage.deleteAll();
  }
}