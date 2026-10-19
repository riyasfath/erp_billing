import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/password_reset_model.dart';

/// Network calls for the forgot-password -> verify-OTP -> reset-password
/// flow. Separate from AuthService/LoginService on purpose.
class PasswordResetService {
  final ApiClient _apiClient;

  PasswordResetService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<String> forgotPassword(ForgotPasswordModel model) async {
    final data =
        await _apiClient.post(ApiEndpoints.forgotPassword, model.toJson());
    return data['message']?.toString() ??
        data['detail']?.toString() ??
        'OTP sent to email';
  }

  Future<String> verifyResetOtp(VerifyResetOtpModel model) async {
    final data =
        await _apiClient.post(ApiEndpoints.verifyResetOtp, model.toJson());
    return data['message']?.toString() ??
        data['detail']?.toString() ??
        'OTP verified successfully';
  }

  Future<String> resetPassword(ResetPasswordModel model) async {
    final data =
        await _apiClient.post(ApiEndpoints.resetPassword, model.toJson());
    return data['message']?.toString() ??
        data['detail']?.toString() ??
        'Password reset successfully';
  }
}