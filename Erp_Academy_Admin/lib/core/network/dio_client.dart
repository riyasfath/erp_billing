import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../storage/token_storage.dart';
import '../utils/jwt_utils.dart';
import 'api_exception.dart';

/// Single configured Dio instance for the whole app.
/// - Base URL & timeouts from .env
/// - Adds `Authorization: Bearer <access>` automatically (except on public calls)
/// - Logs out ONLY when the token is really expired / invalid
/// - Converts every failure to [ApiException]
class DioClient {
  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        sendTimeout: EnvConfig.connectTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublic = options.extra[kPublic] == true;
          if (!isPublic) {
            final token = await _tokenStorage.accessToken;
            if (token != null && token.isNotEmpty) {
              if (JwtUtils.isExpired(token)) {
                debugPrint('🔒 Logout: access token expired '
                    '(exp ${JwtUtils.expiry(token)})');
                onUnauthorized?.call();
                return handler.reject(_sessionExpired(options));
              }
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (e, handler) {
          final isPublic = e.requestOptions.extra[kPublic] == true;
          if (!isPublic && _isTokenInvalid(e.response)) {
            debugPrint('🔒 Logout: server rejected token on '
                '${e.requestOptions.path} → ${e.response?.data}');
            onUnauthorized?.call();
          } else if (e.response?.statusCode == 401) {
            // 401 but not a token problem → show error, DON'T logout
            debugPrint('⚠️ 401 on ${e.requestOptions.path} '
                '(not logging out): ${e.response?.data}');
          }
          handler.next(e);
        },
      ),
    );

    if (kDebugMode && EnvConfig.enableApiLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }

    _shared = this;
  }

  /// Set by AuthViewModel: what to do when the session is no longer valid.
  void Function()? onUnauthorized;

  // ---------- Shared instance ----------
  static DioClient? _shared;

  static DioClient get shared {
    final c = _shared;
    if (c == null) {
      throw StateError('DioClient not created yet. Create it in main() first.');
    }
    return c;
  }

  static const String kPublic = 'public';

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  /// True only when the server says the JWT itself is bad/expired
  /// (Django SimpleJWT: {"code": "token_not_valid", ...}).
  static bool _isTokenInvalid(Response? res) {
    if (res?.statusCode != 401) return false;
    final data = res?.data;
    if (data is! Map) return false;
    final code = data['code']?.toString() ?? '';
    final detail = data['detail']?.toString().toLowerCase() ?? '';
    return code == 'token_not_valid' ||
        (detail.contains('token') &&
            (detail.contains('expired') ||
                detail.contains('not valid') ||
                detail.contains('invalid')));
  }

  static DioException _sessionExpired(RequestOptions options) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: const {'detail': 'Session expired. Please log in again.'},
        ),
      );

  Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? query, bool public = false}) =>
      _wrap(() => _dio.get<T>(path,
          queryParameters: query, options: Options(extra: {kPublic: public})));

  Future<Response<T>> post<T>(String path,
          {Object? data, bool public = false}) =>
      _wrap(() => _dio.post<T>(path,
          data: data, options: Options(extra: {kPublic: public})));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _wrap(() => _dio.put<T>(path, data: data));

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _wrap(() => _dio.patch<T>(path, data: data));

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      _wrap(() => _dio.delete<T>(path, data: data));

  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}