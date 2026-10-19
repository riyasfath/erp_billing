import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'session_manager.dart';
import 'token_storage.dart';

/// Small wrapper around [http.Client] so services never touch raw
/// http/json plumbing. Centralizes timeouts, headers, and error parsing.
///
/// Every request automatically attaches `Authorization: Bearer <token>`
/// when a saved access token exists (from TokenStorage) — endpoints
/// like /api/cart/ require it and were failing with "Authentication
/// credentials were not provided" because this wasn't happening before.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders(Map<String, String>? extra) async {
    final token = await TokenStorage.instance.getAccessToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              ...await _authHeaders(headers),
            },
          )
          .timeout(const Duration(seconds: 25));
    } on SocketException {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    } on HttpException {
      throw ApiException('Something went wrong while contacting the server.');
    } catch (_) {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...await _authHeaders(headers),
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
    } on SocketException {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    } on HttpException {
      throw ApiException('Something went wrong while contacting the server.');
    } catch (_) {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...await _authHeaders(headers),
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
    } on SocketException {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    } on HttpException {
      throw ApiException('Something went wrong while contacting the server.');
    } catch (_) {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              ...await _authHeaders(headers),
            },
          )
          .timeout(const Duration(seconds: 25));
    } on SocketException {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    } on HttpException {
      throw ApiException('Something went wrong while contacting the server.');
    } catch (_) {
      throw ApiException(
        'Could not reach the server. Check your internet connection and try again.',
      );
    }

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> decoded = {};

    if (response.body.isNotEmpty) {
      try {
        final dynamic parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        } else {
          decoded = {'data': parsed};
        }
      } catch (_) {
        decoded = {};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (response.statusCode == 401) {
      // Only treat this as "your session expired" when we actually
      // believed we had one — i.e. a token was really sent with this
      // request. A 401 on /login/ for wrong credentials never has a
      // token attached, so it correctly skips this and just shows a
      // normal error instead of logging the user out app-wide.
      // Fire-and-forget: don't block returning the error to the caller.
      TokenStorage.instance.getAccessToken().then((token) {
        if (token != null && token.isNotEmpty) {
          SessionManager.instance.handleUnauthorized();
        }
      });
    }

    throw ApiException(
      _extractErrorMessage(decoded),
      statusCode: response.statusCode,
      errors: decoded,
    );
  }

  /// Tries the common Django REST Framework error shapes:
  /// {"detail": "..."} / {"message": "..."} / {"non_field_errors": [...]}
  /// / {"email": ["This field is required."]}
  String _extractErrorMessage(Map<String, dynamic> decoded) {
    if (decoded.isEmpty) return 'Something went wrong. Please try again.';

    if (decoded['detail'] is String) return decoded['detail'] as String;
    if (decoded['message'] is String) return decoded['message'] as String;
    if (decoded['error'] is String) return decoded['error'] as String;

    final nonFieldErrors = decoded['non_field_errors'];
    if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
      return nonFieldErrors.first.toString();
    }

    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return 'Something went wrong. Please try again.';
  }
}