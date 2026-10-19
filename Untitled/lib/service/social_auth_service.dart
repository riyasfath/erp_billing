import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/auth_tokens_model.dart';
import 'package:ecommerce_app/models/social_login_model.dart';

/// Network call for /api/accounts/auth/social/ only.
class SocialAuthService {
  final ApiClient _apiClient;

  SocialAuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<AuthTokens> loginWithProvider(SocialLoginModel model) async {
    final data =
        await _apiClient.post(ApiEndpoints.socialLogin, model.toJson());
    return AuthTokens.fromJson(data);
  }
}