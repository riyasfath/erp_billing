import 'dart:convert';

/// Reads the `exp` (expiry) from a JWT without any extra package.
class JwtUtils {
  JwtUtils._();

  static Map<String, dynamic>? decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(payload);
      return map is Map<String, dynamic> ? map : null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? expiry(String token) {
    final exp = decode(token)?['exp'];
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    }
    return null;
  }

  /// True if expired (or unreadable). [leeway] treats "about to expire" as expired.
  static bool isExpired(String token,
      {Duration leeway = const Duration(seconds: 30)}) {
    final e = expiry(token);
    if (e == null) return true;
    return DateTime.now().isAfter(e.subtract(leeway));
  }
}