import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Completely separate session from the customer app's TokenStorage —
/// admin login/logout must never touch or be touched by a customer's
/// session on the same device.
class AdminTokenStorage {
  AdminTokenStorage._();
  static final AdminTokenStorage instance = AdminTokenStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessKey = 'admin_access_token';
  static const _refreshKey = 'admin_refresh_token';
  static const _roleKey = 'admin_role';

  Future<void> saveSession({required String access, required String refresh, required String role}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _roleKey);
  }
}