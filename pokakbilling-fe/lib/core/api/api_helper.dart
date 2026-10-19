import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pokakbilling/core/api/api_exception.dart';
import 'package:pokakbilling/core/api/sessionExpiredService.dart';

/// Central HTTP helper.
/// All responses pass through [_handleResponse].
/// A 401 "session expired" automatically triggers the global logout flow.
class ApiHelper {
  final http.Client _client;
  ApiHelper({http.Client? client}) : _client = client ?? http.Client();

  // ── Public verbs ──────────────────────────────────────────────────────────

  Future<dynamic> get(String url, {Map<String, String>? headers}) =>
      _execute(() => _client.get(Uri.parse(url), headers: headers));

  Future<dynamic> post(String url,
          {Map<String, String>? headers, dynamic body}) =>
      _execute(() => _client.post(Uri.parse(url),
          headers: headers, body: json.encode(body)));

  Future<dynamic> put(String url,
          {Map<String, String>? headers, dynamic body}) =>
      _execute(() => _client.put(Uri.parse(url),
          headers: headers, body: json.encode(body)));

  Future<dynamic> delete(String url, {Map<String, String>? headers}) =>
      _execute(() => _client.delete(Uri.parse(url), headers: headers));

  // ── Core ──────────────────────────────────────────────────────────────────

  Future<dynamic> _execute(Future<http.Response> Function() call) async {
    try {
      final response = await call();
      return _handleResponse(response);
    } on SessionExpiredException {
      rethrow;
    } on SocketException {
      throw FetchDataException("No internet connection.");
    } on HttpException {
      throw FetchDataException("Unexpected HTTP error.");
    } on FormatException {
      throw FetchDataException("Bad response format.");
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body;

    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return json.decode(body);
        } catch (_) {
          return body;
        }

      case 400:
        throw BadRequestException(body);

      case 401:
        // ── Session expiry detection ───────────────────────────────────────
        // Check what your server returns in the body on token expiry.
        // Adjust these strings to match your backend's exact response.
        final lower = body.toLowerCase();
        if (lower.contains("session expired") ||
            lower.contains("token expired") ||
            lower.contains("invalid token")) {
          // This triggers: reset all VMs → SnackBar → navigate to /login
          SessionService.instance.handleSessionExpired();
          throw SessionExpiredException();
        }
        throw UnauthorizedException(body);

      case 403:
        throw ForbiddenException(body);

      case 404:
        throw NotFoundException(body);

      case 422:
        throw UnprocessableContentException(body);

      case 500:
      default:
        throw InternalServerException(
            "Status: ${response.statusCode}, Body: $body");
    }
  }
}
