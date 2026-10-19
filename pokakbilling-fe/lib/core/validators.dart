// lib/core/validators/validators.dart
class Validators {
  Validators._(); // prevent instantiation

  /// Validates numeric-only fields (e.g., pincode)
  /// - required
  /// - digits only
  /// - optional exact length check (if length != null)
  static String? validateDigits(String? value,
      {String fieldName = "Value", int? length}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }

    final digitsRegEx = RegExp(r'^\d+$');
    if (!digitsRegEx.hasMatch(value.trim())) {
      return '$fieldName must contain only digits';
    }

    if (length != null && value.trim().length != length) {
      return '$fieldName must be $length digits';
    }

    return null;
  }

  /// Validates OTP field.
  /// - required
  /// - numeric only
  /// - optional length check (default: 6)
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter OTP';
    }

    final otpRegEx = RegExp(r'^\d+$');
    if (!otpRegEx.hasMatch(value.trim())) {
      return 'OTP must contain only digits';
    }

    if (value.trim().length != length) {
      return 'OTP must be $length digits';
    }

    return null;
  }

  /// Validates first and last name.
  /// - required
  /// - only letters, spaces, hyphens and apostrophes allowed
  static String? validateName(String? value, {String fieldName = "Name"}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }

    // Allow letters, spaces, hyphens and apostrophes (e.g. O'Connor, Mary-Jane)
    final nameRegEx = RegExp(r"^[A-Za-z\s'-]+$");
    if (!nameRegEx.hasMatch(value.trim())) {
      return '$fieldName can contain only letters';
    }

    return null;
  }

  /// Validates email and restricts to gmail addresses.
  static String? validateGmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    // More robust username pattern + gmail domain
    final emailRegEx = RegExp(r"^[A-Za-z0-9._%+-]+@gmail\.com$");
    if (!emailRegEx.hasMatch(value.trim())) {
      return 'Please enter a valid Gmail address (example@gmail.com)';
    }

    return null;
  }

  /// Validates password.
  /// - required
  /// - minimum length (default 6)
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }
}
