// lib/models/services/meeting_services.dart
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';

class MeetingServices {
  /// Create meeting (POST /leads/meeting/)
  /// Note: API expects 'title' key (not 'subject'), plus meeting_type, meeting_place, description etc.
  static Future<String?> createMeeting({
    required int leadId,
    required String date,
    required String time,
    required String status,
    required String title,
    String? meetingType,
    String? meetingPlace,
    String? description,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final Map<String, dynamic> data = {
        'lead': leadId,
        'title': title,
        'date': date,
        'time': time,
        'status': status,
        if (meetingType != null) 'meeting_type': meetingType,
        if (meetingPlace != null) 'meeting_place': meetingPlace,
        if (description != null) 'description': description,
      };

      // DEBUG: print request body (can remove later)
      // ignore: avoid_print
      print(
          'MeetingServices.createMeeting POST ${ApiConstants.meetingEndpoint}');
      // ignore: avoid_print
      print('Request body: $data');

      final response = await dio.post(ApiConstants.meetingEndpoint, data: data);

      // DEBUG: print response (can remove later)
      // ignore: avoid_print
      print('Response (${response.statusCode}): ${response.data}');

      final statusCode = response.statusCode ?? 0;

      if (statusCode == 201 || statusCode == 200) {
        final body = response.data;
        if (body is Map) {
          final st = body['status'];
          if (st == null) {
            // no explicit status -> treat as success
            return null;
          } else {
            final stStr = st.toString();
            if (stStr == '1' || stStr.toLowerCase() == 'true') {
              return null;
            } else {
              final msg = body['message'] ?? body['detail'] ?? body.toString();
              return msg.toString();
            }
          }
        } else {
          // non-map body but 200/201 -> success
          return null;
        }
      } else {
        if (response.data != null) return response.data.toString();
        return 'Failed to create meeting (status ${response.statusCode})';
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) {
        try {
          final d = resp!.data;
          if (d is Map) {
            if (d.containsKey('message')) return d['message'].toString();
            if (d.containsKey('detail')) return d['detail'].toString();
            if (d.containsKey('status')) return d['status'].toString();
            final firstVal = d.values.firstWhere(
              (v) => v is String || v is List,
              orElse: () => d.toString(),
            );
            if (firstVal is String) return firstVal;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            }
            return d.toString();
          }
          return resp.data.toString();
        } catch (_) {
          return resp?.data.toString();
        }
      }
      return "Something went wrong: ${e.message}";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// GET list of meetings
  static Future<List<MeetingModel>> getMeetings() async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.meetingEndpoint);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && (data['status'] == '1' || data['status'] == 1)) {
        final raw = data['data'];
        if (raw is List) {
          return raw
              .map((e) =>
                  MeetingModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        final raw = data['data'] as List;
        return raw
            .map((e) =>
                MeetingModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else if (data is List) {
        return data
            .map((e) =>
                MeetingModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <MeetingModel>[];
    } else {
      throw Exception('Failed to load Meeting. Status: ${response.statusCode}');
    }
  }

  /// GET meetings for a specific lead (server-side)
  /// GET /leads/staff/<leadId>/meeting/
  static Future<List<MeetingModel>> getMeetingsByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = ApiConstants.meetingsByLeadIdEndpoint(leadId);

    try {
      final response = await dio.get(endpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map && data.containsKey('data')) {
          final d = data['data'];
          if (d is List) rawList = d;
        } else if (data is Map && data.containsKey('results')) {
          final r = data['results'];
          if (r is List) rawList = r;
        } else {
          rawList = [];
        }

        return rawList
            .map((e) =>
                MeetingModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } on DioException {
      // ignore and return empty list
    } catch (_) {}
    return <MeetingModel>[];
  }

  /// GET single meeting by id
  static Future<MeetingModel?> getMeetingById(int id) async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.meetingByIdEndpoint(id));

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map) {
        if (data['status'] == '1' && data['data'] is Map) {
          return MeetingModel.fromJson(
              Map<String, dynamic>.from(data['data'] as Map));
        } else if (data.containsKey('data') && data['data'] is Map) {
          return MeetingModel.fromJson(
              Map<String, dynamic>.from(data['data'] as Map));
        } else {
          // If API returns the meeting directly as a map
          return MeetingModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } else {
      throw Exception('Failed to load Meeting');
    }
  }

  /// PATCH update meeting
  static Future<String?> updateMeeting(
      int id, Map<String, dynamic> patchData) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(ApiConstants.meetingByIdEndpoint(id),
          data: patchData);
      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data?.toString() ?? 'Unknown error';
      }
    } on DioException catch (e) {
      return e.response?.data?.toString() ?? 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// DELETE meeting
  static Future<String?> deleteMeeting(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(ApiConstants.meetingByIdEndpoint(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return response.data?.toString() ?? 'Unknown error';
      }
    } on DioException catch (e) {
      return e.response?.data?.toString() ?? "Something went wrong";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
