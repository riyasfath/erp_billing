import 'package:erp_academy/models/app_user_model.dart';

import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../core/utils/jwt_utils.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

/// Talks to the auth APIs. Throws [ApiException] on any failure.
class AuthService {
  AuthService(this._client, this._storage);

  final DioClient _client;
  final TokenStorage _storage;

  Future<LoginResponseModel> adminLogin(
    LoginRequestModel request, {
    required bool remember,
  }) async {
    final res = await _client.post<dynamic>(
      ApiEndpoints.adminLogin,
      data: request.toJson(),
      public: true, // no token on the login call
    );

    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300 || res.data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from server.', statusCode: code);
    }

    final LoginResponseModel login;
    try {
      login = LoginResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on FormatException {
      throw const ApiException('Login failed: invalid response from server.');
    }

    if (remember) {
      // Saved on device → auto-login next time until expiry/logout
      await _storage.saveSession(
        access: login.access,
        refresh: login.refresh,
        userId: login.userId,
        email: login.email,
        isSuperuser: login.isSuperuser,
        remember: true,
      );
    } else {
      // Only this app session → login again after app is closed
      await _storage.clear();
      _storage.setInMemoryAccess(login.access);
    }
    return login;
  }

  /// Called on app start. Returns the user if a remembered, non-expired
  /// session exists; otherwise clears storage and returns null.
  Future<AppUser?> restoreSession() async {
    final s = await _storage.readSession();
    if (s == null) return null;

    if (!s.remember || JwtUtils.isExpired(s.access)) {
      await _storage.clear();
      return null;
    }

    _storage.setInMemoryAccess(s.access);
    return AppUser(
      id: s.userId,
      email: s.email,
      role: s.isSuperuser ? UserRole.admin : UserRole.user,
    );
  }

  Future<void> logout() => _storage.clear();
}