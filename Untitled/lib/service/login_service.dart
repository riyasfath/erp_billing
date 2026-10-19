import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/core/env_config.dart';
import 'package:ecommerce_app/models/auth_tokens_model.dart';
import 'package:ecommerce_app/models/login_model.dart';
import 'package:flutter/foundation.dart';

/// Network call for /login/ only.
class LoginService {
  final ApiClient _apiClient;

  LoginService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AuthTokens> login(LoginModel model) async {
    // TEMP DEBUG — remove once the real cause is found. Prints the
    // EXACT base URL and full URL being hit at runtime.
    debugPrint('[LOGIN DEBUG] EnvConfig.authBaseUrl = "${EnvConfig.authBaseUrl}"');
    debugPrint('[LOGIN DEBUG] Full login URL = "${ApiEndpoints.login}"');

    final data = await _apiClient.post(ApiEndpoints.login, model.toJson());
    return AuthTokens.fromJson(data);
  }
}