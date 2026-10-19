// lib/models/services/activity_services.dart
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';

class ActivityServices {
  /// POST manual activity (ApiConstants.leadActivityManual)
  /// Returns null on success OR a string error message on failure.
  static Future<String?> postManualActivity({
    required int leadId,
    required String activityType,
    required String action,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final payload = {
        'lead': leadId,
        'activity_type': activityType,
        'action': action,
      };

      final resp = await dio.post(ApiConstants.leadActivityManualEndpoint,
          data: payload);

      // success (201/200)
      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        return null;
      }

      // otherwise return server message if present
      try {
        final data = resp.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
      } catch (_) {}
      return 'Failed to post activity: ${resp.statusCode}';
    } on DioException catch (e) {
      // capture server error payload if available
      try {
        if (e.response != null && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('message')) return data['message'].toString();
            if (data.containsKey('detail')) return data['detail'].toString();
            return data.toString();
          } else {
            return data.toString();
          }
        }
      } catch (_) {}
      return e.message ?? 'Network error';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Optionally: if you later get a list endpoint, add methods here to GET activities.
  // For now the viewmodel keeps a local list and relies on postManualActivity to push to server.
}
