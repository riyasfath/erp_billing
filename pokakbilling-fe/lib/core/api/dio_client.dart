
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/core/api/sessionExpiredService.dart';
import 'package:pokakbilling/core/api/api_exception.dart';
import 'package:pokakbilling/models/services/permission_service.dart';

class DioClient {
  static final Dio _dio = Dio();

  static bool _interceptorAdded = false;

  Future<Dio> getAuthorizedDio() async {
    final token = await SecureStorageService().getToken();

    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
      throw Exception('No token found — user is not logged in');
    }

    if (!_interceptorAdded) {
      _dio.interceptors.add(_GlobalErrorInterceptor());
      _interceptorAdded = true;
    }

    return _dio;
  }

  static void clearAuth() {
    _dio.options.headers.remove('Authorization');
  }
}

class _GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    if (statusCode == 403) {
      Future.microtask(() {
        PermissionService.instance.showNoPermissionPopup();
      });

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ForbiddenException('Forbidden'),
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }

    if (statusCode == 401) {
      final body = err.response?.data;
      String message = '';

      if (body is Map) {
        message =
            (body['detail'] ?? body['message'] ?? '').toString().toLowerCase();
      } else if (body is String) {
        message = body.toLowerCase();
      }

      final requestPath = err.requestOptions.path.toLowerCase();
      final isLoginEndpoint = requestPath.contains('/login') ||
          requestPath.contains('/token') ||
          requestPath.contains('/auth');

      final isSessionExpiry = message.contains('session expired') ||
          message.contains('token expired') ||
          message.contains('invalid token') ||
          message.contains('log in again') ||
          (!isLoginEndpoint);

      if (isSessionExpiry) {
        Future.microtask(() {
          SessionService.instance.handleSessionExpired();
        });

        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: SessionExpiredException(),
            type: DioExceptionType.badResponse,
            response: err.response,
          ),
        );
        return;
      }
    }

    handler.next(err);
  }
}
