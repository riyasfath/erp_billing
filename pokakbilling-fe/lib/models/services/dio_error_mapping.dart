import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_exception.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Dio error mapper.
//
// Every service file that uses `DioClient().getAuthorizedDio()` should call
// `mapDioError(e)` as the FIRST line inside its `on DioException catch (e)`
// block, instead of hand-building a "Request failed: ..." string.
//
// WHY: DioClient's global _SessionInterceptor already intercepts 401
// (session expiry) and 403 (permission denied) responses, shows the
// appropriate popup, and rewraps the error before it reaches this layer.
// If a service ignores that and builds its own message from e.message /
// e.response.data, the user sees BOTH the popup AND a big raw error text
// underneath it. mapDioError() prevents that by returning a silent sentinel
// for anything the interceptor already surfaced.
//
// USAGE in a service file:
//
//   } on DioException catch (e) {
//     final mapped = mapDioError(e);
//     if (mapped != null) return mapped;
//     // ...any extra service-specific parsing (e.g. field validation
//     // errors) goes here, only reached for "real" errors.
//     return 'Request failed: ${e.message}';
//   }
//
// USAGE in a ViewModel, wherever a service's String? response is handled:
//
//   } else if (response == kSilentError) {
//     // popup already shown globally — do nothing
//   } else {
//     showOverlayError(context, response);
//   }
// ─────────────────────────────────────────────────────────────────────────────

/// Sentinel returned by service layers for errors that already triggered
/// their own global popup (session expiry, no permission). ViewModels must
/// treat this as "silent" — no further error UI, no success UI either.
const String kSilentError = '__SILENT__';

/// Returns [kSilentError] if this DioException was already handled by the
/// global interceptor (session expiry / permission denied), otherwise
/// returns null so the caller can build its own specific error message.
String? mapDioError(DioException e) {
  // The interceptor rewraps handled errors as one of these exception types.
  if (e.error is SessionExpiredException || e.error is ForbiddenException) {
    return kSilentError;
  }

  // Fallback safety net — in case a request somehow bypasses the
  // interceptor (e.g. a Dio instance created without getAuthorizedDio()).
  final status = e.response?.statusCode;
  if (status == 401 || status == 403) {
    return kSilentError;
  }

  return null;
}
