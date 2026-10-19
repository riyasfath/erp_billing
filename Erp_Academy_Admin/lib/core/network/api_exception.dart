import 'package:dio/dio.dart';

/// Single error type the UI layer deals with. Every Dio/HTTP failure is
/// converted into one of these with a user-readable [message].
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const ApiException(this.message, {this.statusCode, this.type = ApiErrorType.unknown});

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Server is taking too long to respond. Please try again.',
            type: ApiErrorType.timeout);
      case DioExceptionType.connectionError:
        return const ApiException('Unable to reach server. Check your internet connection.',
            type: ApiErrorType.network);
      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.', type: ApiErrorType.cancelled);
      case DioExceptionType.badCertificate:
        return const ApiException('Secure connection failed.', type: ApiErrorType.network);
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      case DioExceptionType.unknown:
        return ApiException(
          e.error is FormatException
              ? 'Invalid response from server.'
              : 'Something went wrong. Please try again.',
        );
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static ApiException _fromResponse(Response? res) {
    final code = res?.statusCode;
    final serverMsg = _extractMessage(res?.data);

    switch (code) {
      case 400:
        return ApiException(serverMsg ?? 'Invalid request.',
            statusCode: code, type: ApiErrorType.badRequest);
      case 401:
        return ApiException(serverMsg ?? 'Invalid email or password.',
            statusCode: code, type: ApiErrorType.unauthorized);
      case 403:
        return ApiException(serverMsg ?? 'You do not have permission to do this.',
            statusCode: code, type: ApiErrorType.forbidden);
      case 404:
        return ApiException(serverMsg ?? 'Requested resource not found.',
            statusCode: code, type: ApiErrorType.notFound);
      default:
        if (code != null && code >= 500) {
          return ApiException('Server error ($code). Please try again later.',
              statusCode: code, type: ApiErrorType.server);
        }
        return ApiException(serverMsg ?? 'Unexpected error (${code ?? 'no status'}).',
            statusCode: code);
    }
  }

  /// Handles Django REST Framework style errors:
  ///  {"detail": "..."}
  ///  {"non_field_errors": ["..."]}
  ///  {"email": ["This field is required."]}
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      for (final entry in data.entries) {
        final v = entry.value;
        final text = v is List && v.isNotEmpty ? v.first.toString() : v?.toString();
        if (text == null || text.isEmpty) continue;
        return entry.key == 'non_field_errors' ? text : '${_label(entry.key)}: $text';
      }
    }
    if (data is String && data.isNotEmpty && !data.trimLeft().startsWith('<')) {
      return data; // ignore HTML error pages
    }
    return null;
  }

  static String _label(String key) =>
      key.isEmpty ? key : key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');

  @override
  String toString() => 'ApiException($statusCode, $type): $message';
}

enum ApiErrorType {
  network,
  timeout,
  cancelled,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
}