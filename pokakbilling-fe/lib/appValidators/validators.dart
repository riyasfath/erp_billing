
class AppValidators {
  AppValidators._();


  static String? firstName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Please enter your first name.';
    if (s.length < 2) {
      return 'First name is too short — at least 2 letters needed.';
    }
    if (s.length > 50) {
      return 'First name is too long — keep it under 50 characters.';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(s)) {
      return 'First name can only have letters, spaces, hyphens, or apostrophes.';
    }
    return null;
  }

  static String? lastName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null; // optional
    if (s.length > 50) {
      return 'Last name is too long — keep it under 50 characters.';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(s)) {
      return 'Last name can only have letters, spaces, hyphens, or apostrophes.';
    }
    return null;
  }

  static String? requiredName(String? v, {String label = 'This field'}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$label is required.';
    if (s.length < 2) return '$label is too short.';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(s)) {
      return '$label can only have letters, spaces, hyphens, or apostrophes.';
    }
    return null;
  }


  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null; // optional
    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(s)) {
      return 'Please enter a valid email address (e.g. name@example.com).';
    }
    return null;
  }

  static String? requiredEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Email address is required.';
    return email(v);
  }

  static String? mobile(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Mobile number is required.';
    if (s.length != 10) return 'Mobile number must be exactly 10 digits.';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(s)) {
      return 'Enter a valid Indian mobile number starting with 6, 7, 8 or 9.';
    }
    return null;
  }

  static String? phone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (s.length != 10) return 'Phone number must be exactly 10 digits.';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(s)) {
      return 'Enter a valid Indian phone number starting with 6, 7, 8 or 9.';
    }
    return null;
  }


  static String? companyName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (s.length < 2) return 'Company name must be at least 2 characters.';
    if (s.length > 100) {
      return 'Company name is too long — keep it under 100 characters.';
    }
    if (!RegExp(r"^[a-zA-Z0-9\s\-&.,()]+$").hasMatch(s)) {
      return 'Company name has invalid characters. Only letters, numbers, spaces, & - . , ( ) are allowed.';
    }
    return null;
  }

  static String? gstNumber(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (s.length < 3) return 'GST number must be at least 3 characters.';
    if (s.length > 20) return 'GST number must be under 20 characters.';
    return null;
  }


  static String? country(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Country is required.';
    if (s.length < 2) return 'Country name must be at least 2 characters.';
    if (!RegExp(r"^[a-zA-Z\s\-]+$").hasMatch(s)) {
      return 'Country name can only contain letters.';
    }
    return null;
  }

  static String? state(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'State is required.';
    if (s.length < 2) return 'State name must be at least 2 characters.';
    if (!RegExp(r"^[a-zA-Z\s\-]+$").hasMatch(s)) {
      return 'State name can only contain letters.';
    }
    return null;
  }

  static String? address(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (s.length < 5) return 'Address must be at least 5 characters.';
    if (s.length > 200) {
      return 'Address is too long — keep it under 200 characters.';
    }
    if (!RegExp(r"^[A-Za-z0-9\s,.\-/#]+$").hasMatch(s)) {
      return 'Address contains invalid characters. Only letters, numbers, spaces, and , . - / # are allowed.';
    }
    return null;
  }


  static String? fullName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Full name is required.';
    if (s.length < 2) {
      return 'Name is too short — at least 2 characters needed.';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(s)) {
      return 'Name can only contain letters, spaces, hyphens, or apostrophes.';
    }
    return null;
  }

  static String? date(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final parts = s.split('/');
    if (parts.length != 3) return 'Use the format dd / mm / yyyy.';
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (day < 1 || day > 31) return 'Day must be between 1 and 31.';
      if (month < 1 || month > 12) return 'Month must be between 1 and 12.';
      if (year < 1900 || year > 2100) {
        return 'Year must be between 1900 and 2100.';
      }
      DateTime(year, month, day); // throws if invalid combo
      return null;
    } catch (_) {
      return 'Please enter a valid date.';
    }
  }

  static String? requiredPhone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Phone number is required.';
    if (!RegExp(r'^[0-9]+$').hasMatch(s)) {
      return 'Phone number can only contain digits.';
    }
    if (s.length != 10) return 'Phone number must be exactly 10 digits.';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(s)) {
      return 'Enter a valid number starting with 6, 7, 8 or 9.';
    }
    return null;
  }

  static String? leadSource(String? v, {required bool hasSelection}) {
    if (!hasSelection || v == null || v.trim().isEmpty) {
      return 'Please tap and select a lead source.';
    }
    return null;
  }

  static String? leadStatus(String? v) {
    if (v == null || v.isEmpty) return 'Please select a lead status.';
    return null;
  }

  static String? otherCategoryDetail(String? v,
      {required bool isOtherSelected}) {
    if (!isOtherSelected) return null;
    if (v == null || v.trim().isEmpty) {
      return 'Please describe the category type.';
    }
    return null;
  }


  static String? required(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? minMax(
    String? v, {
    required String label,
    int? min,
    int? max,
    bool isRequired = false,
  }) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) {
      return isRequired ? '$label is required.' : null;
    }
    if (min != null && s.length < min) {
      return '$label must be at least $min characters.';
    }
    if (max != null && s.length > max) {
      return '$label must be under $max characters.';
    }
    return null;
  }
}
