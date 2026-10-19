// lib/models/services/followup_services.dart
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';

class FollowupServices {
  /// GET all followups (staff-scoped)
  /// GET /leads/staff/followups/
  static Future<List<FollowupModel>> getFollowups() async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.followupsEndpoint);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      try {
        List<dynamic> rawList = [];

        if (data is Map && data.containsKey('data')) {
          final d = data['data'];
          if (d is List) rawList = d;
        } else if (data is List) {
          rawList = data;
        } else if (data is Map && data.containsKey('results')) {
          final r = data['results'];
          if (r is List) rawList = r;
        } else {
          rawList = [];
        }

        final List<FollowupModel> list = rawList
            .map((e) =>
                FollowupModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return list;
      } catch (e) {
        return <FollowupModel>[];
      }
    } else {
      return <FollowupModel>[];
    }
  }

  /// GET followups for a specific lead (server-side filtered)
  /// GET /leads/staff/<leadId>/followup/
  static Future<List<FollowupModel>> getFollowupsByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = ApiConstants.followupsByLeadIdEndpoint(leadId);

    try {
      final response = await dio.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // API likely returns a list, but handle {status,data:[...]} shape too
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
                FollowupModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        return <FollowupModel>[];
      }
    } on DioException {
      // If API returns non-200, return empty list; caller can handle errors
      return <FollowupModel>[];
    } catch (e) {
      return <FollowupModel>[];
    }
  }

  /// Create a followup
  /// POST /leads/staff/followups/
  /// body: { lead, title, date, time, status, type, notes }
  static Future<FollowupModel?> createFollowup({
    required int lead,
    required String title,
    required String date, // yyyy-mm-dd
    required String time, // HH:mm
    required String status, // new/completed
    required String type, // call/meeting/email/whatsapp
    String notes = '',
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final Map<String, dynamic> payload = {
        'lead': lead,
        'title': title,
        'date': date,
        'time': time,
        'status': status,
        'type': type,
        'notes': notes,
      };

      final response =
          await dio.post(ApiConstants.followupsEndpoint, data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final d = response.data;
        if (d is Map) {
          if (d.containsKey('data') && d['data'] is Map) {
            return FollowupModel.fromJson(Map<String, dynamic>.from(d['data']));
          }
          if (d.containsKey('id') || d.containsKey('lead')) {
            return FollowupModel.fromJson(Map<String, dynamic>.from(d));
          }
        }
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) {
        try {
          if (resp!.data is Map && (resp.data as Map).containsKey('detail')) {
            throw Exception(resp.data['detail'].toString());
          } else {
            throw Exception(resp.data.toString());
          }
        } catch (_) {
          throw Exception('Request failed: ${e.message}');
        }
      }
      throw Exception('Request failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
