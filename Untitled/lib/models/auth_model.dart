/// Data sent to /register/.
class RegisterModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;

  RegisterModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'terms_accepted': termsAccepted,
      };
}

/// Data sent to /register-verify/.
class OtpModel {
  final String email;
  final String otp;

  OtpModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}