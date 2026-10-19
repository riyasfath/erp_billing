import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'admin_token_storage.dart';

/// Thrown by [AdminApiClient] on any network error or non-2xx response.
/// [message] is always safe to show directly on screen.
class AdminApiException implements Exception {
  final String message;
  AdminApiException(this.message);

  @override
  String toString() => message;
}

/// Small HTTP wrapper for the admin module — separate from the
/// customer app's ApiClient because it needs multipart/form-data
/// support (product create/update/image-upload all use it) and reads
/// the admin's own token, not the customer's.
class AdminApiClient {
  final http.Client _client;

  AdminApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AdminTokenStorage.instance.getAccessToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json', ...await _authHeaders()})
          .timeout(const Duration(seconds: 25));
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json', ...await _authHeaders()},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> putJson(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json', ...await _authHeaders()},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> patchJson(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json', ...await _authHeaders()},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: {'Accept': 'application/json', ...await _authHeaders()})
          .timeout(const Duration(seconds: 25));
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  /// multipart/form-data request — used for product create/update
  /// (text fields + optional new image files) and standalone image
  /// upload. [method] is 'POST' or 'PUT'.
  Future<Map<String, dynamic>> multipart(
    String method,
    String url, {
    Map<String, String> fields = const {},
    List<File> images = const [],
    String imagesFieldName = 'images',
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(await _authHeaders());
      request.fields.addAll(fields);
      for (final file in images) {
        request.files.add(await http.MultipartFile.fromPath(imagesFieldName, file.path));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamed);
      return _handle(response);
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  /// Raw authenticated GET for binary responses (PDF export).
  Future<List<int>> getBytes(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: {...await _authHeaders()})
          .timeout(const Duration(seconds: 40));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      throw AdminApiException('Export failed (status ${response.statusCode}).');
    } on SocketException {
      throw AdminApiException('Could not reach the server. Check your connection.');
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw AdminApiException('Something went wrong. Please try again.');
    }
  }

  Map<String, dynamic> _handle(http.Response response) {
    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        decoded = parsed is Map<String, dynamic> ? parsed : {'data': parsed};
      } catch (_) {
        decoded = {};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return decoded;

    throw AdminApiException(_extractError(decoded));
  }

  String _extractError(Map<String, dynamic> decoded) {
    if (decoded.isEmpty) return 'Something went wrong. Please try again.';
    if (decoded['detail'] is String) return decoded['detail'] as String;
    if (decoded['error'] is String) return decoded['error'] as String;
    if (decoded['message'] is String) return decoded['message'] as String;
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return 'Something went wrong. Please try again.';
  }
}