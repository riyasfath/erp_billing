/// Thrown by [ApiClient] whenever a request fails — network error,
/// timeout, or a non-2xx HTTP response. [message] is always safe to
/// show directly to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}