// lib/models/services/reminder_service.dart
// ✅ Updated for NEW API structure
// POST /reminders/ -> { title, lead, subtype, due_date, description, status }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';

class ReminderServices {
  /// Helper to combine date and time into ISO format
  static String _combineDateTimeToISO(String date, String time) {
    String combined = '${date}T$time';

    // Ensure time has seconds
    final timeParts = time.split(':');
    if (timeParts.length == 2) {
      combined = '${date}T$time:00';
    }

    // Add Z for UTC if not present
    if (!combined.endsWith('Z') && !combined.contains('+')) {
      combined += 'Z';
    }

    return combined;
  }

  /// GET all reminders
  /// GET /reminders/
  /// Supports filters: ?status=PENDING&due_date_after=YYYY-MM-DD
  static Future<List<ReminderModel>> fetchReminders({
    String? leadId,
    String? status,
    String? dueDateAfter,
    String? dueDateBefore,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    try {
      final queryParams = <String, dynamic>{};
      if (leadId != null && leadId.isNotEmpty) queryParams['lead'] = leadId;
      if (status != null) queryParams['status'] = status;
      if (dueDateAfter != null) queryParams['due_date_after'] = dueDateAfter;
      if (dueDateBefore != null) queryParams['due_date_before'] = dueDateBefore;

      final response = await dio.get(
        ApiConstants.remindersEndpoint,
        queryParameters: queryParams,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final body = response.data;

        if (body is List) {
          return body
              .whereType<Map>()
              .map((m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        }

        if (body is Map) {
          if (body.containsKey('data') && body['data'] is List) {
            final raw = body['data'] as List;
            return raw
                .whereType<Map>()
                .map(
                    (m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
                .toList();
          }
          if (body.containsKey('results') && body['results'] is List) {
            final raw = body['results'] as List;
            return raw
                .whereType<Map>()
                .map(
                    (m) => ReminderModel.fromJson(Map<String, dynamic>.from(m)))
                .toList();
          }
          try {
            return [ReminderModel.fromJson(Map<String, dynamic>.from(body))];
          } catch (_) {
            return [];
          }
        }

        return [];
      } else {
        throw Exception('Failed to fetch reminders (status $statusCode)');
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) {
        throw Exception(resp!.data.toString());
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// GET reminders for a specific lead
  /// GET /leads/{id}/reminders/
  static Future<List<ReminderModel>> getRemindersByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = '${ApiConstants.leadsEndpoint}$leadId/reminders/';

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
        }

        return rawList
            .map((e) =>
                ReminderModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } on DioException catch (_) {
      // ignore and return empty list
    } catch (_) {}
    return <ReminderModel>[];
  }

  /// GET reminder stats
  /// GET /reminders/stats/
  static Future<Map<String, dynamic>> getReminderStats() async {
    final dio = await DioClient().getAuthorizedDio();

    try {
      final response = await dio.get(ApiConstants.remindersStatsEndpoint);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Create a reminder
  /// POST /reminders/
  /// NEW API Payload: { title, lead, subtype, due_date, description, status }
  static Future<String?> createReminder({
    required String lead,
    required String title,
    required String
        subtype, // "Email", "Call", "WhatsApp", "Message", "Follow-up"
    String? dueDate, // ISO 8601: 2024-01-10T09:00:00Z
    String? description,
    String status = 'PENDING',
    // Legacy parameters for backward compatibility
    String? date,
    String? time,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      // Determine final dueDate
      String finalDueDate;
      if (dueDate != null && dueDate.isNotEmpty) {
        finalDueDate = dueDate;
      } else if (date != null && time != null) {
        // Use legacy date + time
        finalDueDate = _combineDateTimeToISO(date, time);
      } else {
        return 'Date and time are required';
      }

      // Validate required fields
      if (title.isEmpty) {
        return 'Title is required';
      }

      if (subtype.isEmpty) {
        return 'Subtype is required';
      }

      // ✅ NEW API payload structure - exactly matching the API spec
      final data = {
        'title': title,
        'lead': int.tryParse(lead) ?? lead, // API expects integer
        'subtype': subtype,
        'due_date': finalDueDate,
        'status': status,
      };

      // Only add description if it's not empty
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }

      final response =
          await dio.post(ApiConstants.remindersEndpoint, data: data);

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final body = response.data;

        // ✅ NEW: Check if response contains the created reminder object
        if (body is Map) {
          // If response has 'id' field, it's a successful creation
          if (body.containsKey('id')) {
            return null; // Success - reminder was created
          }

          // Check for explicit error indicators
          if (body.containsKey('error') || body.containsKey('errors')) {
            final msg = body['error'] ?? body['errors'] ?? body['message'];
            return msg.toString();
          }

          // Legacy status check for backward compatibility
          final st = body['status'];
          if (st == null) {
            return null; // Success
          } else {
            final stStr = st.toString();
            if (stStr == '1' ||
                stStr.toLowerCase() == 'true' ||
                stStr.toUpperCase() == 'PENDING') {
              return null; // Success
            } else if (stStr.toLowerCase() == 'false' || stStr == '0') {
              final msg = body['message'] ??
                  body['detail'] ??
                  'Failed to create reminder';
              return msg.toString();
            }
          }

          // If we have activity_type REMINDER, it's successful
          if (body['activity_type']?.toString() == 'REMINDER') {
            return null; // Success
          }

          return null; // Default to success for 200/201 responses
        } else {
          return null; // Success
        }
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

  /// Create reminder and return the created object
  /// POST /reminders/
  static Future<ReminderModel> createReminderAndReturn({
    required String lead,
    required String title,
    required String subtype,
    required String date,
    required String time,
    String? description,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    // Convert to ISO format
    final dueDate = _combineDateTimeToISO(date, time);

    // ✅ NEW API payload structure
    final data = {
      'title': title,
      'lead': int.tryParse(lead) ?? lead,
      'subtype': subtype,
      'due_date': dueDate,
      'status': 'PENDING',
    };

    if (description != null && description.isNotEmpty) {
      data['description'] = description;
    }

    final response = await dio.post(ApiConstants.remindersEndpoint, data: data);

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

      throw Exception('Unexpected create response format');
    } else {
      throw Exception(
          'Failed to create reminder (status ${response.statusCode})');
    }
  }

  /// GET single reminder by id
  /// GET /reminders/{id}/
  static Future<ReminderModel> getReminder(String id) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = ApiConstants.reminderByIdEndpoint(int.parse(id));

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

  /// Update reminder (PUT/PATCH)
  /// PUT /reminders/{id}/
  static Future<ReminderModel?> updateReminder(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = ApiConstants.reminderByIdEndpoint(int.parse(id));

    // Ensure updates use the correct API field names
    final apiUpdates = <String, dynamic>{};
    updates.forEach((key, value) {
      // Map old field names to new API names
      switch (key) {
        case 'subject':
          apiUpdates['title'] = value;
          break;
        case 'type':
          apiUpdates['subtype'] = value;
          break;
        case 'notes':
          apiUpdates['description'] = value;
          break;
        default:
          apiUpdates[key] = value;
      }
    });

    final response = await dio.put(url, data: apiUpdates);

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

  /// Mark reminder as completed
  /// PUT /reminders/{id}/ with status='COMPLETED'
  /// Mark reminder as completed
  /// PUT /reminders/{id}/ with status='COMPLETED'
  /// Mark reminder as completed
  /// Tries PATCH first, falls back to PUT
  static Future<String?> markCompleted(String id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.patch(
        ApiConstants.reminderByIdEndpoint(int.parse(id)),
        data: {'status': 'COMPLETED'},
      );

      debugPrint(
          '✅ Reminder markCompleted PATCH ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // success
      }
      return response.data.toString();
    } on DioException catch (e) {
      debugPrint('❌ Reminder markCompleted PATCH failed');
      debugPrint('   status : ${e.response?.statusCode}');
      debugPrint('   body   : ${e.response?.data}');
      debugPrint('   message: ${e.message}');

      // Fallback to PUT
      try {
        final dio2 = await DioClient().getAuthorizedDio();
        final response2 = await dio2.put(
          ApiConstants.reminderByIdEndpoint(int.parse(id)),
          data: {'status': 'COMPLETED'},
        );

        debugPrint(
            '✅ Reminder markCompleted PUT fallback ${response2.statusCode}: ${response2.data}');

        if (response2.statusCode == 200 || response2.statusCode == 204) {
          return null; // success
        }
        return response2.data.toString();
      } on DioException catch (e2) {
        debugPrint('❌ Reminder markCompleted PUT also failed');
        debugPrint('   status : ${e2.response?.statusCode}');
        debugPrint('   body   : ${e2.response?.data}');
        return e2.response?.data?.toString() ??
            e2.message ??
            'Something went wrong.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Delete reminder
  /// DELETE /reminders/{id}/
  static Future<bool> deleteReminder(String id) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = ApiConstants.reminderByIdEndpoint(int.parse(id));

    final response = await dio.delete(url);

    return (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 202);
  }
}
