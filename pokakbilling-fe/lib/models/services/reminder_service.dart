// lib/models/services/reminder_services.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';

class ReminderServices {
  /// GET list of reminders. If leadId provided, will add as query param 'lead'.
  static Future<List<ReminderModel>> fetchReminders({String? leadId}) async {
    final dio = await DioClient().getAuthorizedDio();
    try {
      final query = <String, dynamic>{};
      if (leadId != null && leadId.isNotEmpty) query['lead'] = leadId;

      final response = await dio.get(ApiConstants.staffRemindersEndpoint,
          queryParameters: query);

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        return _parseList(response.data);
      } else {
        throw Exception('Failed to fetch reminders (status $statusCode)');
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) throw Exception(resp!.data.toString());
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// GET reminders for a specific lead
  /// GET /leads/staff/<leadId>/reminder/
  static Future<List<ReminderModel>> getRemindersByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = ApiConstants.remindersByLeadIdEndpoint(leadId);

    debugPrint('=== getRemindersByLead GET $endpoint ===');

    try {
      final response = await dio.get(endpoint);
      debugPrint(
          '=== getRemindersByLead status=${response.statusCode} body=${response.data} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseList(response.data);
      } else {
        throw Exception(
            'Failed to fetch reminders for lead $leadId (status ${response.statusCode})');
      }
    } on DioException catch (e) {
      final resp = e.response;
      debugPrint(
          '=== getRemindersByLead DioError status=${resp?.statusCode} body=${resp?.data} ===');
      if (resp?.data != null) throw Exception(resp!.data.toString());
      throw Exception('Network error fetching reminders: ${e.message}');
    } catch (e) {
      debugPrint('=== getRemindersByLead error: $e ===');
      rethrow;
    }
  }

  /// Shared list parser — handles List, {data:[]}, {results:[]}
  static List<ReminderModel> _parseList(dynamic body) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    if (body is Map) {
      if (body.containsKey('data') && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map>()
            .map((m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      if (body.containsKey('results') && body['results'] is List) {
        return (body['results'] as List)
            .whereType<Map>()
            .map((m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      // single object
      try {
        return [ReminderModel.fromJson(Map<String, dynamic>.from(body))];
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// POST create reminder
  static Future<String?> createReminder({
    required String lead,
    required String title,
    required String type,
    required String date,
    required String time,
    String? description,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = {
        'lead': lead,
        'title': title,
        'type': type,
        'date': date,
        'time': time,
        if (description != null) 'description': description,
      };

      debugPrint(
          'ReminderServices.createReminder POST ${ApiConstants.staffRemindersEndpoint}');
      debugPrint('Request body: $data');

      final response =
          await dio.post(ApiConstants.staffRemindersEndpoint, data: data);

      debugPrint('Response (${response.statusCode}): ${response.data}');

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final body = response.data;
        if (body is Map) {
          final st = body['status'];
          if (st == null) return null;
          final stStr = st.toString();
          if (stStr == '1' || stStr.toLowerCase() == 'true') return null;
          final msg = body['message'] ?? body['detail'] ?? body.toString();
          return msg.toString();
        }
        return null;
      } else {
        if (response.data != null) return response.data.toString();
        return 'Failed to create reminder (status $statusCode)';
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) {
        try {
          final d = resp!.data;
          if (d is Map) {
            if (d.containsKey('message')) return d['message'].toString();
            if (d.containsKey('detail')) return d['detail'].toString();
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

  /// POST create and return created ReminderModel
  static Future<ReminderModel> createReminderAndReturn({
    required String lead,
    required String title,
    required String type,
    required String date,
    required String time,
    String? description,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final data = {
      'lead': lead,
      'title': title,
      'type': type,
      'date': date,
      'time': time,
      if (description != null) 'description': description,
    };

    debugPrint(
        'createReminderAndReturn POST ${ApiConstants.staffRemindersEndpoint}');
    debugPrint('body: $data');

    final response =
        await dio.post(ApiConstants.staffRemindersEndpoint, data: data);

    debugPrint(
        'createReminderAndReturn response (${response.statusCode}): ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final raw = body['data'];
        if (raw is List && raw.isNotEmpty && raw[0] is Map) {
          return ReminderModel.fromJson(
              Map<String, dynamic>.from(raw[0] as Map));
        } else if (raw is Map) {
          return ReminderModel.fromJson(Map<String, dynamic>.from(raw));
        }
      } else if (body is List && body.isNotEmpty && body[0] is Map) {
        return ReminderModel.fromJson(
            Map<String, dynamic>.from(body[0] as Map));
      } else if (body is Map) {
        return ReminderModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected create response format: $body');
    } else {
      throw Exception(
          'Failed to create reminder (status ${response.statusCode})');
    }
  }

  /// GET single reminder by id
  static Future<ReminderModel> getReminder(String id) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = '${ApiConstants.staffRemindersEndpoint}$id/';
    final response = await dio.get(url);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data;
      if (body is Map) {
        return ReminderModel.fromJson(Map<String, dynamic>.from(body));
      } else if (body is List && body.isNotEmpty && body[0] is Map) {
        return ReminderModel.fromJson(
            Map<String, dynamic>.from(body[0] as Map));
      }
    }
    throw Exception('Failed to fetch reminder (status ${response.statusCode})');
  }

  /// PATCH partial update
  static Future<ReminderModel?> updateReminder(
      String id, Map<String, dynamic> updates) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = '${ApiConstants.staffRemindersEndpoint}$id/';
    final response = await dio.patch(url, data: updates);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data;
      if (body is Map) {
        return ReminderModel.fromJson(Map<String, dynamic>.from(body));
      } else if (body is List && body.isNotEmpty && body[0] is Map) {
        return ReminderModel.fromJson(
            Map<String, dynamic>.from(body[0] as Map));
      }
      return null;
    } else {
      throw Exception(
          'Failed to update reminder (status ${response.statusCode})');
    }
  }

  /// Mark completed
  static Future<bool> markCompleted(String id) async {
    try {
      final updated =
          await updateReminder(id, {'status': 'completed', 'completed': true});
      return updated != null;
    } catch (_) {
      try {
        final dio = await DioClient().getAuthorizedDio();
        final url = '${ApiConstants.staffRemindersEndpoint}$id/';
        final response = await dio.patch(url, data: {'status': 'completed'});
        return (response.statusCode == 200 || response.statusCode == 201);
      } catch (e) {
        rethrow;
      }
    }
  }

  /// DELETE reminder
  static Future<bool> deleteReminder(String id) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = '${ApiConstants.staffRemindersEndpoint}$id/';
    final response = await dio.delete(url);
    return (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 202);
  }
}
