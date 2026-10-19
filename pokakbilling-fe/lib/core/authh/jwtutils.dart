import 'dart:convert';

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw const FormatException('Invalid JWT');
  final normalized = base64Url.normalize(parts[1]);
  final payload = utf8.decode(base64Url.decode(normalized));
  final map = json.decode(payload);
  if (map is! Map<String, dynamic>) {
    throw const FormatException('Invalid JWT payload');
  }
  return map;
}

int? userIdFromToken(String token) {
  try {
    final payload = decodeJwtPayload(token);
    final raw = payload['user_id'] ?? payload['id'] ?? payload['sub'];
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  } catch (_) {
    return null;
  }
}
