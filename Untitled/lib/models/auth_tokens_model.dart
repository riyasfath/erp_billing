/// Reads access/refresh tokens out of a JSON response body regardless of
/// which of the common DRF shapes the backend uses:
///   {"access": "...", "refresh": "..."}
///   {"access_token": "...", "refresh_token": "..."}
///   {"token": {"access": "...", "refresh": "..."}}
///   {"tokens": {...}}  /  {"data": {...}}
/// If the real response uses a different key, add it to the candidate
/// lists below — nothing else needs to change.
class AuthTokens {
  final String? accessToken;
  final String? refreshToken;
  final String message;
  final Map<String, dynamic> raw;

  AuthTokens({
    this.accessToken,
    this.refreshToken,
    this.message = '',
    this.raw = const {},
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> src = json;

    for (final wrapperKey in ['token', 'tokens', 'data']) {
      final wrapper = json[wrapperKey];
      if (wrapper is Map<String, dynamic>) {
        src = {...src, ...wrapper};
      }
    }

    String? firstNonEmpty(List<String> keys) {
      for (final key in keys) {
        final value = src[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    return AuthTokens(
      accessToken:
          firstNonEmpty(['access', 'access_token', 'accessToken', 'token']),
      refreshToken:
          firstNonEmpty(['refresh', 'refresh_token', 'refreshToken']),
      message: json['message']?.toString() ?? json['detail']?.toString() ?? '',
      raw: json,
    );
  }

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
}