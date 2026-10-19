/// Central place for every form-field validator used across the app.
/// Keep UI widgets free of regex/logic — they should only ever call
/// `Validators.xxx` and show the returned message (or nothing if null).
class Validators {
  Validators._();

  // ---------------------------------------------------------------------
  // Regex patterns
  // ---------------------------------------------------------------------

  /// Letters (any language), spaces, apostrophes and hyphens only.
  /// Blocks digits and symbols — use for Full Name style fields.
  static final RegExp _textOnlyPattern =
      RegExp(r"^[a-zA-Z\u00C0-\u024F\s'-]+$");

  /// Standard, practical email pattern (not full RFC 5322, but catches
  /// the real-world mistakes: missing '@', missing domain, no TLD, etc).
  static final RegExp _emailPattern =
      RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
          r"(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
          r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$");

  /// Digits only — use for OTP, phone number, quantity, etc.
  static final RegExp _numberOnlyPattern = RegExp(r'^[0-9]+$');

  // ---------------------------------------------------------------------
  // Individual validators — each returns null when valid, else an
  // error message safe to show directly under the field.
  // ---------------------------------------------------------------------

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Text-only field (e.g. Full Name). No digits, no symbols.
  static String? textOnly(String? value, {String fieldName = 'This field'}) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!_textOnlyPattern.hasMatch(trimmed)) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  /// Email field — format-checked, not just "contains @".
  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Numbers-only field (OTP, phone, etc). [exactLength] enforces a
  /// fixed length (e.g. 6 for OTP) when provided.
  static String? numberOnly(
    String? value, {
    String fieldName = 'This field',
    int? exactLength,
    int? minLength,
    int? maxLength,
  }) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    if (!_numberOnlyPattern.hasMatch(trimmed)) {
      return '$fieldName can only contain numbers';
    }
    if (exactLength != null && trimmed.length != exactLength) {
      return '$fieldName must be $exactLength digits';
    }
    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName must be at least $minLength digits';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName must be at most $maxLength digits';
    }
    return null;
  }

  /// OTP shortcut — 6-digit numeric code.
  static String? otp(String? value, {int length = 6}) {
    return numberOnly(value, fieldName: 'OTP', exactLength: length);
  }

  /// Password: min 8 chars, at least one letter and one number.
  /// Adjust the rules here if backend enforces something different.
  static String? password(String? value) {
    final requiredError = required(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;

    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Confirm-password: must be non-empty and match [original].
  static String? confirmPassword(String? value, String original) {
    final requiredError = required(value, fieldName: 'Confirm password');
    if (requiredError != null) return requiredError;

    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}

/// Flutter [TextInputFormatter]s that stop invalid characters from being
/// typed in the first place (in addition to the Validators above, which
/// run on submit). Import `package:flutter/services.dart` where you use
/// these — kept separate here so this file has no Flutter UI dependency.
class InputPatterns {
  InputPatterns._();

  /// RegExp source for a TextInputFormatter.
  static const String textOnlySource = r"[a-zA-Z\u00C0-\u024F\s'\-]";
  static const String numberOnlySource = r'[0-9]';
}