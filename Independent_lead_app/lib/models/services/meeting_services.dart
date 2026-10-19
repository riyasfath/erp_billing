// lib/models/services/meeting_services.dart
// ✅ UPDATED: Full support for NEW API endpoints & structure
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';

class MeetingServices {
  /// GET all meetings - /meetings/
  static Future<List<MeetingModel>> getMeetings({
    String? status,
    String? dueDateAfter,
    String? dueDateBefore,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final queryParams = <String, dynamic>{};

    if (status != null) queryParams['status'] = status;
    if (dueDateAfter != null) queryParams['due_date_after'] = dueDateAfter;
    if (dueDateBefore != null) queryParams['due_date_before'] = dueDateBefore;

    try {
      final response = await dio.get(
        ApiConstants.meetingsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          rawList = data['results'] ?? data['data'] ?? [];
        }

        return rawList
            .map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET meetings for specific lead - /leads/{id}/meetings/
  static Future<List<MeetingModel>> getMeetingsByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = '${ApiConstants.leadsEndpoint}$leadId/meetings/';

    try {
      final response = await dio.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          rawList = data['results'] ?? data['data'] ?? [];
        }

        return rawList
            .map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET meeting stats - /meetings/stats/
  static Future<Map<String, dynamic>> getMeetingStats() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.meetingsStatsEndpoint);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// CREATE meeting - POST /meetings/
  static Future<String?> createMeeting({
    required int leadId,
    required String title,
    required String dueDate, // ISO: "2024-01-05T14:00:00Z"
    String status = 'PENDING',
    String? subtype, // "Video Call", "In-Person"
    String? location, // "zoom.us/meet"
    String? description,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final payload = {
        'lead': leadId,
        'title': title,
        'due_date': dueDate,
        'status': status,
        if (subtype != null) 'subtype': subtype,
        if (location != null) 'location': location,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      final response =
          await dio.post(ApiConstants.meetingsEndpoint, data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      }
      return response.data.toString();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// GET single meeting - GET /meetings/{id}/
  static Future<MeetingModel?> getMeetingById(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.meetingByIdEndpoint(id));

      if (response.statusCode == 200) {
        return MeetingModel.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// UPDATE meeting - PUT /meetings/{id}/
  static Future<String?> updateMeeting(
      int id, Map<String, dynamic> updates) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.put(ApiConstants.meetingByIdEndpoint(id), data: updates);

      if (response.statusCode == 200) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// DELETE meeting - DELETE /meetings/{id}/
  static Future<String?> deleteMeeting(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(ApiConstants.meetingByIdEndpoint(id));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Mark completed
  static Future<String?> markCompleted(int id) async {
    return updateMeeting(id, {'status': 'COMPLETED'});
  }

  /// Mark cancelled
  static Future<String?> markCancelled(int id) async {
    return updateMeeting(id, {'status': 'CANCELLED'});
  }

  static String? _handleDioError(DioException e) {
    final resp = e.response;
    if (resp?.data != null) {
      try {
        final errorData = resp!.data;
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            return errorData['detail'].toString();
          }
          for (var value in errorData.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            } else if (value is String) {
              return value;
            }
          }
        }
        return errorData.toString();
      } catch (_) {
        return 'Validation failed';
      }
    }
    return 'Request failed: ${e.message}';
  }
}
