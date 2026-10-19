/// Data sent to /api/accounts/forgot-password/.
class ForgotPasswordModel {
  final String email;

  ForgotPasswordModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

/// Data sent to /api/accounts/verify-otp/ (password-reset OTP — separate
/// endpoint from the signup /register-verify/ OTP).
class VerifyResetOtpModel {
  final String email;
  final String otp;

  VerifyResetOtpModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}

/// Data sent to /api/accounts/reset-password/.
class ResetPasswordModel {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordModel({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      };
}