import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/auth_model.dart';
import 'package:ecommerce_app/models/auth_tokens_model.dart';

/// Network calls for the register -> verify-OTP flow only.
/// Login lives in [LoginService] — kept separate on purpose.
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Returns the backend's success message (or a sensible default).
  Future<String> register(RegisterModel model) async {
    final data = await _apiClient.post(ApiEndpoints.register, model.toJson());
    return data['message']?.toString() ??
        data['detail']?.toString() ??
        'Registration successful. Check your email for the OTP.';
  }

  /// Returns tokens if the backend logs the user in immediately after
  /// OTP verification (accessToken will be null if it doesn't).
  Future<AuthTokens> verifyOtp(OtpModel model) async {
    final data =
        await _apiClient.post(ApiEndpoints.registerVerify, model.toJson());
    return AuthTokens.fromJson(data);
  }
}