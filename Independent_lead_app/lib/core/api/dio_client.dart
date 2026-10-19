import 'package:dio/dio.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/core/api/session_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  DioClient._internal();

  Future<Dio> getAuthorizedDio() async {
    final dio = Dio(
      BaseOptions(
        headers: {
          "Content-Type": "application/json",
        },
        validateStatus: (status) => true,
      ),
    );

    String? token;
    try {
      token = await SecureStorageService().getToken();
    } catch (e) {
      print('[DioClient] Failed to read token: $e');
    }

    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('[DioClient] WARNING: No auth token found.');
    }

    // ── Session expiry interceptor ────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.statusCode == 401 || response.statusCode == 403) {
            // Fire and forget — don't await, just trigger the dialog
            SessionService.instance.handleSessionExpired();
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          final status = e.response?.statusCode;
          if (status == 401 || status == 403) {
            SessionService.instance.handleSessionExpired();
          }
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}
